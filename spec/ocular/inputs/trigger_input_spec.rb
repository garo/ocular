require 'ocular'
require 'faraday'
require 'pp'

RSpec.describe Ocular::Inputs::Trigger::Input do

    it "be created" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")
        settings = Ocular::Settings.get(:inputs)

        input = ::Ocular::Inputs::Trigger::Input.new(settings)
    end

    it "can add an evaluator" do
        Ocular::Settings.load_from_file("spec/data/settings.yaml")
        settings = Ocular::Settings.get(:inputs)

        input = ::Ocular::Inputs::Trigger::Input.new(settings)

        #input.add_evaluator()
    end

=begin
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


    end
=end

end