require 'ocular'
require 'faraday'
require 'pp'

RSpec.describe Ocular::Inputs::Cron::Input do

    it "can start its server and schedule one event" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")

        input = ::Ocular::Inputs::Cron::Input.new(Ocular::Settings)
        input.start()

        s = false
        input.scheduler.in '0.1s' do
            s = true
        end

        while s == false
            sleep 0.1
        end
        #response = Faraday.get("http://localhost:#{settings[:http][:port]}/does_not_exists")
        expect(s).to eq(true)
        input.stop()
    end

    describe "#dsl" do
        it "#cron.in can be used to schedule an event without forking" do
            ef = Ocular::Event::EventFactory.new
            s = false
            proxy = ef.load_from_block "test_dsl" do
                fork false
                cron.in "0.1s" do
                    s = true
                end
            end
            
            input = ef.handlers.get(::Ocular::Inputs::Cron::Input)

            while s == false
                sleep 0.1
            end
            expect(s).to eq(true)

            input.stop()

        end

        it "#cron.in can be used to schedule an event with forking" do
            ef = Ocular::Event::EventFactory.new

            proxy = ef.load_from_block "test_dsl" do
                fork true
                cron.in "0.1s" do
                    puts "from inside fork"
                end                             
            end
            
            input = ef.handlers.get(::Ocular::Inputs::Cron::Input)
            input.stop()
        end

        it "#cron.every won't fire if cron is disabled" do
            ef = Ocular::Event::EventFactory.new
            s = false
            input = ef.handlers.get(::Ocular::Inputs::Cron::Input)
            input.disable

            proxy = ef.load_from_block "test_dsl" do
                fork false
                cron.every "0.3s" do
                    s = true
                end                             
            end

            sleep 0.5
            expect(s).to eq(false)
            input.enable
            while s == false
                sleep 0.1
            end
            expect(s).to eq(true)

            input.stop()

        end

    end
 
end