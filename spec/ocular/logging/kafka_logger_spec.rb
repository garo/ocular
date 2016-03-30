require 'ocular'


RSpec.describe Ocular::Logging::KafkaLogger do
    class Producer
        attr_accessor :messages

        def initialize
            @messages = []
        end
        def produce(msg, topic:, partition: nil, partition_key: nil)
            @messages << [msg, topic]
        end
        def deliver_messages

        end
    end

    class TestKafka
        attr_accessor :producer

        def initialize
            @producer = Producer.new
        end
    end

    it "can be created" do
        settings = {}
        kafka = TestKafka.new

        a = ::Ocular::Logging::KafkaLogger.new(settings, kafka)
        expect(a).not_to eq(nil)
    end

    it "will send logs to kafka" do
        settings = {
            :topic => "the topic"
        }

        kafka = TestKafka.new
        a = ::Ocular::Logging::KafkaLogger.new(settings, kafka)

        a.add(Ocular::Logging::Severity::INFO, "Hello, World!", "runid")

        expect(kafka.producer.messages[0][1]).to eq("the topic")

        data = JSON.parse(kafka.producer.messages[0][0])

        expect(data["level"]).to eq("INFO")
        expect(data["msg"]).to eq("Hello, World!")
        expect(data["run_id"]).to eq("runid")
    end

    it "will send logs to kafka" do
        settings = {
            :topic => "the topic"
        }

        kafka = TestKafka.new
        a = ::Ocular::Logging::KafkaLogger.new(settings, kafka)

        a.log_event("foo", "bar", "runid")

        expect(kafka.producer.messages[0][1]).to eq("the topic")

        data = JSON.parse(kafka.producer.messages[0][0])

        expect(data["run_id"]).to eq("runid")
        expect(data["foo"]).to eq("bar")
    end

end

