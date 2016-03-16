require 'ocular'


RSpec.describe Ocular::DSL::Etcd do

    it "#etcd returns object" do
        ::Ocular::Settings.load_from_file('spec/data/settings.yaml')

        ef = Ocular::Event::EventFactory.new
        a = nil
        proxy = ef.load_from_block "test_dsl" do
            fork false
            onEvent "name" do
                a = etcd()
            end                             
        end
        eventbase = proxy.events["onEvent"]["name"]

        context = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
        eventbase.exec(context)
        expect(a).not_to eq(nil)
    end

end

