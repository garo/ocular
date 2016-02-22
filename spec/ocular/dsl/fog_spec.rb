require 'ocular'


RSpec.describe Ocular::DSL::Fog do

    it "#aws returns object" do
        ::Ocular::Settings.load_from_file('spec/data/settings.yaml')

        a = nil
        ef = Ocular::Event::EventFactory.new
        proxy = ef.load_from_block "test_dsl" do
            onEvent nil do
                a = aws()
            end                             
        end
        eventbase = proxy.events[0]

        context = Ocular::DSL::RunContext.new
        eventbase.exec(context)
        expect(a).not_to eq(nil)
    end

    it "#aws returns object" do
        ::Ocular::Settings.load_from_file('spec/data/settings.yaml')

        a = nil
        ef = Ocular::Event::EventFactory.new
        proxy = ef.load_from_block "test_dsl" do
            onEvent nil do
                a = autoscaling()
            end                             
        end
        eventbase = proxy.events[0]

        context = Ocular::DSL::RunContext.new
        eventbase.exec(context)
        expect(a).not_to eq(nil)
    end    
end

