require 'ocular'


RSpec.describe Ocular::DSL::Logging do

    it "#debug can be used to log a string" do
        rc = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
        rc.debug("debug msg")
    end

    it "#info can be used to log a string" do
        rc = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
        rc.info("info msg")
    end

    it "#warn can be used to log a string" do
        rc = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
        rc.warn("warn msg")
    end

    it "#error can be used to log a string" do
        rc = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
        rc.error("error msg")
    end
    
    it "#fatal can be used to log a string" do
        rc = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
        rc.fatal("fatal msg")
    end

end

