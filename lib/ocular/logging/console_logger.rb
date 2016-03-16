
class Ocular
    module Logging

        # Most of the Logger class is copied from the Ruby Logger class source code.
        class ConsoleLogger

            def initialize()
                @level = Severity::DEBUG
                @formatter = Logger::Formatter.new
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
    
                puts format_message(format_severity(severity), Time.now, run_id, message)
                true
            end

            SEV_LABEL = %w(DEBUG INFO WARN ERROR FATAL ANY).each(&:freeze).freeze

            def format_severity(severity)
                SEV_LABEL[severity] || 'ANY'
            end            

            def format_message(severity, datetime, progname, msg)
                @formatter.call(severity, datetime, progname, msg)
            end

            # Default formatter for log messages.
            class Formatter
                Format = "%s, [%s#%d] %5s -- %s: %s\n".freeze

                attr_accessor :datetime_format

                def initialize
                    @datetime_format = nil
                end

                def call(severity, time, progname, msg)
                    Format % [severity[0..0], format_datetime(time), $$, severity, progname, msg2str(msg)]
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
