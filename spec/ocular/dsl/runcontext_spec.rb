require 'ocular'


RSpec.describe Ocular::DSL::RunContext do

    describe "#initialize" do
        it "sets run_id to an uuid" do
            rc = Ocular::DSL::RunContext.new
            expect(rc.run_id).not_to eq("")
            expect(rc.run_id).not_to eq(nil)
            expect(rc.run_id).to match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
        end
    end

    describe "#Logging" do
        it "#debug can be used to log a string" do
            rc = Ocular::DSL::RunContext.new
            rc.debug("debug msg")
        end

        it "#info can be used to log a string" do
            rc = Ocular::DSL::RunContext.new
            rc.debug("info msg")
        end

        it "#warn can be used to log a string" do
            rc = Ocular::DSL::RunContext.new
            rc.debug("warn msg")
        end

        it "#error can be used to log a string" do
            rc = Ocular::DSL::RunContext.new
            rc.debug("error msg")
        end
        
        it "#fatal can be used to log a string" do
            rc = Ocular::DSL::RunContext.new
            rc.debug("fatal msg")
        end


    end
end

