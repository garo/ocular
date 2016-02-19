require 'ocular'


RSpec.describe Ocular::DSL::SSH do


    it "#to_ssh returns object" do
        a = nil
        ef = Ocular::Event::EventFactory.new
        proxy = ef.load_from_block "test_dsl" do
            onEvent EventFactoryTestClass do
                a = ssh_to("localhost")
            end                             
        end
        eventbase = proxy.events[0]

        context = Ocular::DSL::RunContext.new
        eventbase.exec(context)
        expect(a).not_to eq(nil)

    end

end

