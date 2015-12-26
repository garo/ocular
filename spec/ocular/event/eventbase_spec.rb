require 'ocular'

RSpec.describe Ocular::DSL::EventBase do

    describe "#exec" do
        it "can call a block with run_context" do
            a = false
            test = Ocular::DSL::EventBase.new do
                a = true
                setVariable(true)
            end

            class TestRunContext
                attr_accessor :variable

                def initialize
                    @variable = false
                end

                def setVariable(val)
                    @variable = val
                end
            end

            context = TestRunContext.new

            test.exec(context)
            expect(context.variable).to eq(true)
            expect(a).to eq(true)
        end
    end
end

