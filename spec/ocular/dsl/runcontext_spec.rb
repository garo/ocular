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

end

