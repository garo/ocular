require 'ocular/inputs/handlers.rb'
require 'ocular/event/eventbase.rb'
require 'ocular/inputs/http_input.rb'

class Ocular
    module Event
        class DefinitionProxy
            attr_accessor :events
            attr_reader :script_name, :do_fork
            attr_accessor :handlers, :events

            def initialize(script_name, handlers)
                @script_name = script_name
                @events = {}
                @logger = Ocular::DSL::Logger.new
                @handlers = handlers
                @do_fork = true
            end

            include Ocular::Mixin::FromFile
            include Ocular::DSL::Logging
            include Ocular::DSL::SSH
            include Ocular::DSL::Fog
            include Ocular::DSL::Etcd

            include Ocular::Inputs::HTTP::DSL

            def fork(value)
                @do_fork = value
            end

            def onEvent(type, &block)
                eventbase = Ocular::DSL::EventBase.new(&block)
                eventbase.proxy = self
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

                proxy = DefinitionProxy.new(name, @handlers)
                proxy.from_file(file)
                @files[name] = proxy
                return proxy
            end

            def load_from_block(name, &block)
                proxy = DefinitionProxy.new(name, @handlers)
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
