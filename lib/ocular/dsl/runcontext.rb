
require 'securerandom'
require 'ocular/inputs/cron_input'

class Ocular
    module DSL
        class RunContext
            attr_accessor :run_id
            attr_accessor :proxy
            attr_accessor :class_name
            attr_accessor :event_signature
            attr_accessor :logger

            include Ocular::DSL::Logging
            include Ocular::DSL::SSH
            include Ocular::DSL::Fog
            include Ocular::DSL::Etcd
            include Ocular::DSL::Orbit
            include Ocular::DSL::MySQL
            include Ocular::DSL::RabbitMQ
            include Ocular::DSL::Graphite
            include Ocular::DSL::Cache

            include Ocular::Inputs::Cron::DSL

            def initialize(logger)
                @run_id = SecureRandom.uuid()
                @logger = logger
                @cleanups = []
            end

            def method_missing(method_sym, *arguments, &block)
                if self.proxy
                    self.proxy.send(method_sym, *arguments, &block)
                else
                    raise NoMethodError, "undefined method `#{method_sym}` in event #{self.class_name}"
                end
            end

            def register_cleanup(&block)
                @cleanups << block
            end

            def cleanup()
                for i in @cleanups
                    i.call()
                end
            end

            def after_fork()
                @logger.reconnect()
            end
        end

        class REPLRunContext < RunContext
            attr_reader :handlers
            attr_reader :events
            attr_reader :do_fork
            attr_reader :logger

            def initialize(handlers, logger)
                super(logger)
                @events = {}
                @handlers = handlers
                @do_fork = false
            end
        end
    end
end
