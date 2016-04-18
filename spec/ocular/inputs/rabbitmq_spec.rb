require 'ocular'
require 'faraday'
require 'pp'

RSpec.describe Ocular::Inputs::RabbitMQ::Input do

    describe "#dsl" do
        it "#rabbitmq.subscribe can be used to read messages via amqp" do
            ef = Ocular::Event::EventFactory.new
            s = false
            proxy = ef.load_from_block "test_dsl" do
                fork false
                q = amqp.queue("test1", :exclusive => false, :auto_delete => true)

                rabbitmq.subscribe(q.name, :auto_delete => true) do
                    puts "A: Processing message #{delivery_info.delivery_tag} with payload #{payload}"
                    s = payload
                end

                amqp.default_exchange.publish("moi", :routing_key => q.name)
            end

            while s == false
                sleep 1
            end
            
            input = ef.handlers.get(::Ocular::Inputs::RabbitMQ::Input)
            expect(s).to eq("moi")

            input.stop()
        end

        it "#rabbitmq.subscribe can be used to read messages via amqp with fork" do
            ef = Ocular::Event::EventFactory.new
            s = false
            id = nil
            proxy = ef.load_from_block "test_dsl" do
                fork true
                q = amqp.queue("test2", :exclusive => false, :auto_delete => true)
                id = rabbitmq.subscribe(q.name, :auto_delete => true) do
                    puts "B: Processing message #{delivery_info.delivery_tag} with payload #{payload}"
                end

                amqp.default_exchange.publish("hei", :routing_key => q.name)

            end

            while true
                sleep 1
                if proxy.events[id].last_run
                    expect(proxy.events[id].last_run.payload).to eq("hei")
                    break
                end
            end
            
            input = ef.handlers.get(::Ocular::Inputs::RabbitMQ::Input)
            input.stop()
        end        
    end
 
end
