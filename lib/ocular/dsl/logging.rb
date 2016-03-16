require 'logger'

class Ocular
    module DSL
        module Logging

            def debug(message = nil, &block)
                @logger.add(::Ocular::Logging::Severity::DEBUG, message, @run_id, &block)
            end
            alias log debug

            def info(message = nil, &block)
                @logger.add(::Ocular::Logging::Severity::INFO, message, @run_id, &block)
            end

            def warn(message = nil, &block)
                @logger.add(::Ocular::Logging::Severity::WARN, message, @run_id, &block)
            end

            def error(message = nil, &block)
                @logger.add(::Ocular::Logging::Severity::ERROR, message, @run_id, &block)
            end

            def fatal(message = nil, &block)
                @logger.add(::Ocular::Logging::Severity::FATAL, message, @run_id, &block)
            end

            def log_event(property, value)
                @logger.log_event(property, value, @run_id)
            end

        end
    end
end
