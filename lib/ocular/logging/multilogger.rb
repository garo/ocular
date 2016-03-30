
require 'pp'

class Ocular
    module Logging
        class MultiLogger
            attr_reader :loggers

            def initialize
                @loggers = []
            end

            def add_logger(logger)
                @loggers << logger
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

                if message.nil?
                    if block_given?
                        message = yield
                    else
                        message = "N/A"
                    end
                end

                @loggers.each do |logger|
                    logger.add(severity, message, run_id)
                end
                true
            end

            def log_event(property, value, run_id)
                @loggers.each do |logger|
                    logger.log_event(property, value, run_id)
                end
                true
            end

            def log_cause(type, environment, run_id)
                @loggers.each do |logger|
                    logger.log_cause(type, environment, run_id)
                end
                true
            end

            def log_timing(key, value, run_id)
                @loggers.each do |logger|
                    logger.log_timing(key, value, run_id)
                end
                true
            end        
        end
    end
end
