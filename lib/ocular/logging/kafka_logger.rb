require "kafka"

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
                    @kafka = Kafka.new(settings)
                end
                @settings = settings

                @producer = @kafka.producer
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
    
                @producer.produce(@formatter.format_message(severity, Time.now, run_id, message), topic: @settings[:topic], partition_key: run_id)
            end

            def log_event(property, value, run_id = nil)
                @producer.produce(@formatter.format_event(property, value, Time.now, run_id), topic: @settings[:topic], partition_key: run_id)
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
                        "ts" => format_datetime(time),
                        "run_id" => progname,
                        "msg" => msg2str(msg)
                    } 
                    return data.to_json
                end

                def format_event(property, value, time, progname)
                    data = {
                        "ts" => format_datetime(time),
                        "run_id" => progname,
                    }
                    data[property] = value
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
            end
        end
    end
end
