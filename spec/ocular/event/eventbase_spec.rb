require 'ocular'

RSpec.describe Ocular::DSL::EventBase do

    describe "#exec" do
        it "can call a block with run_context" do
            a = false
            proxy = {}
            test = Ocular::DSL::EventBase.new(proxy) do
                a = true
                setVariable(true)
            end

            class TestRunContext
                attr_accessor :variable
                attr_accessor :proxy
                attr_accessor :timing

                def initialize
                    @variable = false
                    @timing = []
                end

                def setVariable(val)
                    @variable = val
                end

                def log_timing(key, value)
                    timing << [key, value]
                end
            end

            context = TestRunContext.new

            test.exec(context, do_fork=false)
            expect(context.variable).to eq(true)
            expect(context.timing[0][0]).to eq("execution_time")
            expect(a).to eq(true)
        end

        it "can return big amounts of data from forked exec" do
            proxy = {}
            test = Ocular::DSL::EventBase.new(proxy) do
                return "x"*65537
            end
            
            context = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
            ret = test.exec_fork(context)

            expect(ret.length).to eq(65537)

        end
    end
end

