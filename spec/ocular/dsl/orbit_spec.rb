require 'ocular'


RSpec.describe Ocular::DSL::Orbit do

    it "#orbit returns object" do
        ::Ocular::Settings.load_from_file('spec/data/settings.yaml')

        ef = Ocular::Event::EventFactory.new
        a = nil
        proxy = ef.load_from_block "test_dsl" do
            fork false
            onEvent "name" do
                a = orbit()
            end                             
        end
        eventbase = proxy.events["onEvent"]["name"]

        context = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
        eventbase.exec(context)
        expect(a).not_to eq(nil)
    end

    it "#orbit.get_service_endpoints works" do
        ::Ocular::Settings.load_from_file('spec/data/settings.yaml')

        ef = Ocular::Event::EventFactory.new
        a = nil
        proxy = ef.load_from_block "test_dsl" do
            fork false
            onEvent "name" do
                a = orbit.get_service_endpoints("servicename")
            end                             
        end
        eventbase = proxy.events["onEvent"]["name"]

        context = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
        eventbase.exec(context)
        expect(a).not_to eq(nil)
    end

end

