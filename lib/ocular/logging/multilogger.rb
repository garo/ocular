

class Ocular
    module Logging
        class MultiLogger
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

        end
    end
end
