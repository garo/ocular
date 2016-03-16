require 'ocular'


RSpec.describe Ocular::DSL::Logging do
    class TestLogger
        attr_accessor :msg
        def initialize
            @msg = []
        end

        def add(severity, message = nil, run_id = nil, &block)
            @msg << [severity, message, run_id]
        end

        def log_event(property, value, run_id = nil, &block)
            @msg << [property, value, run_id]
        end
    end

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

    it "#log_event can be used to log a string" do
        l = TestLogger.new
        rc = Ocular::DSL::RunContext.new(l)
        rc.log_event("foo", "bar")
        expect(l.msg[0][0]).to eq("foo")
        expect(l.msg[0][1]).to eq("bar")
    end


end

