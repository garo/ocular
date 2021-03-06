require 'pathname'

require 'ocular/inputs/handlers.rb'
require 'ocular/event/eventbase.rb'
require 'ocular/inputs/http_input.rb'
require 'ocular/inputs/cron_input.rb'
require 'ocular/inputs/trigger_input.rb'
require 'ocular/inputs/rabbitmq_input.rb'

class Ocular
    module Event
        class DefinitionProxy
            attr_accessor :events
            attr_reader :script_name, :do_fork, :logger, :dirname
            attr_accessor :handlers, :events

            def initialize(script_name, dirname, handlers)
                @script_name = script_name
                @dirname = dirname
                @events = {}
                @logger = ::Ocular.logger
                @handlers = handlers
                @do_fork = true
            end

            include Ocular::Mixin::FromFile
            include Ocular::DSL::Logging
            include Ocular::DSL::SSH
            include Ocular::DSL::Fog
            include Ocular::DSL::Etcd
            include Ocular::DSL::MySQL
            include Ocular::DSL::Psql
            include Ocular::DSL::Mongo
            include Ocular::DSL::RabbitMQ
            include Ocular::DSL::Graphite
            include Ocular::DSL::Cache
            include Ocular::DSL::File

            include Ocular::Inputs::HTTP::DSL
            include Ocular::Inputs::HTTP::ErrorDSL
            include Ocular::Inputs::Cron::DSL
            include Ocular::Inputs::Trigger::DSL
            include Ocular::Inputs::RabbitMQ::DSL

            def fork(value)
                @do_fork = value
            end

            def onEvent(type, &block)
                eventbase = Ocular::DSL::EventBase.new(self, &block)
                (@events["onEvent"] ||= {})[type] = eventbase
            end
        end

        class EventFactory

            attr_accessor :handlers
            attr_accessor :files

            def initialize
                @files = {}
                @handlers = ::Ocular::Inputs::Handlers.new
            end
            
            def load_from_file(file, name = nil)
                if !name
                    name = file
                end

                pn = Pathname.new(file)

                proxy = DefinitionProxy.new(name, pn.dirname, @handlers)
                proxy.from_file(file)
                @files[name] = proxy
                return proxy
            end

            def load_from_block(name, &block)
                proxy = DefinitionProxy.new(name, "./", @handlers)
                proxy.instance_eval(&block)
                @files[name] = proxy
                return proxy
            end

            def get(name)
                return @files[name]
            end

            def start_input_handlers()
                @handlers.start()
            end

            def stop_input_handlers()
                @handlers.stop()
            end
        end
    end
end
