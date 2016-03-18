require 'ocular'


RSpec.describe Ocular::Logging::MultiLogger do

    it "can be created" do
        a = ::Ocular::Logging::MultiLogger.new
        expect(a).not_to eq(nil)
    end

    it "will forward logs to multiple loggers" do
        a = ::Ocular::Logging::MultiLogger.new

        class TestLogger
            attr_accessor :msg
            def initialize
                @msg = []
            end

            def add(severity, message = nil, run_id = nil, &block)
                @msg << [severity, message, run_id]
            end
        end

        b = TestLogger.new
        c = TestLogger.new
        a.add_logger(b)
        a.add_logger(c)

        a.add(Ocular::Logging::Severity::INFO, "Hello, World!")

        expect(b.msg[0][0]).to eq(Ocular::Logging::Severity::INFO)
        expect(b.msg[0][1]).to eq("Hello, World!")
        expect(c.msg[0][0]).to eq(Ocular::Logging::Severity::INFO)
        expect(c.msg[0][1]).to eq("Hello, World!")
    end

    it "will forward events to multiple loggers" do
        a = ::Ocular::Logging::MultiLogger.new

        class TestLogger
            attr_accessor :msg
            def initialize
                @msg = []
            end

            def log_event(property, value, run_id = nil, &block)
                @msg << [property, value, run_id]
            end
        end

        b = TestLogger.new
        c = TestLogger.new
        a.add_logger(b)
        a.add_logger(c)

        a.log_event("foo", "bar", "run_id")

        expect(b.msg[0][0]).to eq("foo")
        expect(b.msg[0][1]).to eq("bar")
        expect(c.msg[0][0]).to eq("foo")
        expect(c.msg[0][1]).to eq("bar")
    end

end

