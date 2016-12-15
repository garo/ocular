require 'ocular'


RSpec.describe Ocular::DSL::Mongo do

    it "#mongo returns object inside event" do
        ::Ocular::Settings.load_from_file('spec/data/settings.yaml')

        ef = Ocular::Event::EventFactory.new
        a = "nan"
        proxy = ef.load_from_block "test_dsl" do
            fork false
            onEvent "name" do
                a = mongo()
            end
        end
        eventbase = proxy.events["onEvent"]["name"]

        context = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
        eventbase.exec(context)
        expect(a).not_to eq(nil)
    end

    it "#mongo returns object outside event" do
        ::Ocular::Settings.load_from_file('spec/data/settings.yaml')

        ef = Ocular::Event::EventFactory.new
        a = "nan"
        proxy = ef.load_from_block "test_dsl" do
            a = mongo()
        end

        context = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
        expect(a).not_to eq(nil)
    end
end

