require 'ocular'


RSpec.describe Ocular::DSL::RunContext do

    describe "#initialize" do
        it "sets run_id to an uuid" do
            rc = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)
            expect(rc.run_id).not_to eq("")
            expect(rc.run_id).not_to eq(nil)
            expect(rc.run_id).to match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
        end
    end

    it "can register cleanup function" do
        rc = Ocular::DSL::RunContext.new(Ocular::Logging::ConsoleLogger.new)

        a = false
        rc.register_cleanup do
            a = true
        end

        rc.cleanup()

        expect(a).to eq(true)
    end

    it "can log inside fork" do
        logger = Ocular::Logging::MultiLogger.new
        console_logger = Ocular::Logging::ConsoleLogger.new
        console_logger.set_level("DEBUG")
        kafka_logger = Ocular::Logging::KafkaLogger.new({
            :client => {
                :seed_brokers => [
                    "kafka-a-1.us-east-1.applifier.info:9092"
                ]
            }
            }, nil)
        logger.add_logger(console_logger)
        logger.add_logger(kafka_logger)
        logger.log("Warming logging up")
        context = Ocular::DSL::RunContext.new(logger)
        proxy = Ocular::Event::DefinitionProxy.new("test script", "./", {:handlers => true})
        context.log_cause("test:can log inside fork", {:foo => "bar"})
        eventbase = Ocular::DSL::EventBase.new(proxy) do
            puts "Logging inside fork!!!"
        end

        eventbase.exec(context)



    end

end

