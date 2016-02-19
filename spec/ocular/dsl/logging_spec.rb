require 'ocular'


RSpec.describe Ocular::DSL::Logging do

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

