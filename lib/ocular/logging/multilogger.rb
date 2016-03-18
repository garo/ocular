
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
    
            end

            def log_event(property, value, run_id)
                @loggers.each do |logger|
                    logger.log_event(property, value, run_id)
                end
            end

            def log_cause(type, environment, run_id)
                @loggers.each do |logger|
                    logger.log_cause(type, environment, run_id)
                end
            end

            def log_timing(key, value, run_id)
                @loggers.each do |logger|
                    logger.log_timing(key, value, run_id)
                end
            end        
        end
    end
end
