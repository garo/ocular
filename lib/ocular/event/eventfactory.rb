require 'ocular/inputs/handlers.rb'
require 'ocular/event/eventbase.rb'
require 'ocular/inputs/http_input.rb'

class Ocular
    module Event
        class DefinitionProxy
          attr_accessor :events
          attr_accessor :klass_name
          attr_accessor :handlers

          def initialize(klass_name, handlers)
            self.klass_name = klass_name
            @events = []
            @logger = Ocular::DSL::Logger.new
            @handlers = handlers
          end

          include Ocular::Mixin::FromFile
          include Ocular::DSL::Logging
          include Ocular::DSL::SSH
          include Ocular::DSL::Fog
          include Ocular::Inputs::HTTP::DSL

          def onEvent(factory_class, &block)
            eventbase = Ocular::DSL::EventBase.new(&block)
            eventbase.proxy = self
            @events << eventbase
          end
        end

        class EventFactory

            def initialize
                @files = {}
                @handlers = ::Ocular::Inputs::Handlers.new
            end
            
            def load_from_file(file)
                proxy = DefinitionProxy.new(file, @handlers)
                proxy.from_file(file)
                @files[file] = proxy
                return proxy
            end

            def load_from_block(name, &block)
                proxy = DefinitionProxy.new(name, @handlers)
                proxy.instance_eval(&block)
                @files[name] = proxy
                return proxy
            end

        end
    end
end