
class Ocular
    module Logging

        # Most of the Logger class is copied from the Ruby Logger class source code.
        class ConsoleLogger

            def initialize(settings=nil)
                @level = Severity::DEBUG
                @formatter = Formatter.new
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
    
                puts @formatter.format_message(severity, Time.now, message)
                true
            end

            def log_event(property, value, run_id = nil)
                puts @formatter.format_event(property, value, Time.now)
                true
            end            

            def log_cause(type, environment, run_id = nil)
                puts @formatter.format_cause(type, environment, Time.now)
                true
            end

            def log_timing(key, value, run_id = nil)
                puts @formatter.format_timing(key, value, Time.now)
                true
            end            

            # Default formatter for log messages.
            class Formatter
                Format = "[%s#%d] %s -- %s\n".freeze
                EventFormat = "[%s#%d] -- %s: %s\n".freeze
                CauseFormat = "[%s#%d] -- %s triggered processing with environment: %s\n".freeze
                TimingFormat = "[%s#%d] -- %s took %s ms\n".freeze

                attr_accessor :datetime_format

                def initialize
                    @datetime_format = nil
                end

                def format_message(severity, time, msg)
                    Format % [format_datetime(time), $$, Ocular::Logging::Severity::LABELS[severity], msg2str(msg)]
                end

                def format_event(property, value, time)
                    EventFormat % [format_datetime(time), $$, property, value]
                end

                def format_cause(type, environment, time)
                    CauseFormat % [format_datetime(time), $$, type, environment.to_json]
                end

                def format_timing(key, value, time)
                    TimingFormat % [format_datetime(time), $$, key, value]
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
