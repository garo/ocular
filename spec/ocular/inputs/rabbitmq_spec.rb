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
                rabbitmq.subscribe("ocular-test") do
                    s = payload
                end

                amqp.default_exchange.publish("moi", :routing_key => "ocular-test")
            end

            while s == false
                sleep 1
            end
            
            input = ef.handlers.get(::Ocular::Inputs::RabbitMQ::Input)
            expect(s).to eq("moi")

            input.stop()

        end
    end
 
end
