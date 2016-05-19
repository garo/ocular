require "kafka"
require "socket"

class Ocular
    module Logging

        # Most of the Logger class is copied from the Ruby Logger class source code.
        class KafkaLogger

            def initialize(settings=nil, kafka=nil)
                @level = Severity::DEBUG
                @formatter = Formatter.new

                if kafka != nil
                    @kafka = kafka
                else
                    pp settings
                    @kafka = Kafka.new(settings[:client])
                end
                @settings = settings

                @producer = @kafka.producer
            end

            def reconnect()
                @kafka = Kafka.new(@settings[:client])
            end

            def debug(message = nil, &block)
                add(Severity::DEBUG, message, @run_id, &block)
            end
            alias log debug

            def info(message = nil, &block)
                add(Severity::INFO, message, @run_id, &block)
            end

            def warn(message = nil, &block)
                add(Severity::WARN, message, @run_id, &block)
            end

            def error(message = nil, &block)
                add(Severity::ERROR, message, @run_id, &block)
            end

            def fatal(message = nil, &block)
                add(Severity::FATAL, message, @run_id, &block)
            end

            def add(severity, message = nil, run_id = nil, &block)
                severity ||= Severity::UNKNOWN
                if severity < @level
                    return true
                end

                if message.nil?
                    if block_given?
                        message = yield
                    else
                        message = progname
                    end
                end

                begin
                    @producer.produce(@formatter.format_message(severity, Time.now, run_id, message), topic: @settings[:topic], partition_key: run_id)
                    @producer.deliver_messages
                rescue StandardError => e
                    STDERR.puts "Error on producing kafka message: #{e}"
                end
            end

            def log_event(property, value, run_id = nil)
                begin
                    @producer.produce(@formatter.format_event(property, value, Time.now, run_id), topic: @settings[:topic], partition_key: run_id)
                    @producer.deliver_messages
                rescue StandardError => e
                    STDERR.puts "Error on producing kafka log_event: #{e}"
                end
            end

            def log_cause(type, environment, run_id = nil)
                begin
                    @producer.produce(@formatter.format_cause(type, environment, Time.now, run_id), topic: @settings[:topic], partition_key: run_id)
                    @producer.deliver_messages
                rescue StandardError => e
                    STDERR.puts "Error on producing kafka log_cause: #{e}"
                end

            end

            def log_timing(key, value, run_id = nil)
                begin
                    @producer.produce(@formatter.format_event("timing:" + key, value, Time.now, run_id), topic: @settings[:topic], partition_key: run_id)
                    @producer.deliver_messages
                rescue StandardError => e
                    STDERR.puts "Error on producing kafka log_timing: #{e}"
                end

            end

            # Default formatter for log messages.
            class Formatter
                Format = "%s, [%s#%d] %5s -- %s: %s\n".freeze

                attr_accessor :datetime_format

                def initialize
                    @datetime_format = nil
                end

                def format_message(severity, time, progname, msg)
                    data = {
                        "level" => Ocular::Logging::Severity::LABELS[severity],
                        "@timestamp" => format_datetime(time),
                        "run_id" => progname,
                        "msg" => msg2str(msg),
                        "host" => hostname
                    }
                    return data.to_json
                end

                def format_event(property, value, time, progname)
                    data = {
                        "@timestamp" => format_datetime(time),
                        "run_id" => progname,
                        "host" => hostname
                    }
                    data[property] = value
                    return data.to_json
                end                

                def format_cause(type, environment, time, progname)
                    data = {
                        "@timestamp" => format_datetime(time),
                        "run_id" => progname,
                        "triggered_by" => type,
                        "environment" => environment,
                        "host" => hostname
                    }

                    return data.to_json
                end

            private

                def format_datetime(time)
                    time.strftime(@datetime_format || "%Y-%m-%dT%H:%M:%S.%6N ".freeze)
                end

                def msg2str(msg)
                    case msg
                    when ::String
                        msg
                    when ::Exception
                        "#{ msg.message } (#{ msg.class })\n" <<
                        (msg.backtrace || []).join("\n")
                    else
                        msg.inspect
                    end
                end

                def hostname
                    if !@hostname
                        @hostname = Socket.gethostname
                    end
                    return @hostname
                end
            end
        end
    end
end
