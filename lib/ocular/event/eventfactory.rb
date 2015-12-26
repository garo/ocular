require 'ocular/event/eventbase.rb'

class Ocular
    module Event
        class DefinitionProxy
          attr_accessor :events

          def initialize
            @events = []
          end

          include Ocular::Mixin::FromFile

          def onEvent(factory_class, &block)
            eventbase = Ocular::DSL::EventBase.new(&block)
            @events << eventbase
          end
        end

        class EventFactory

            def initialize
                @files = {}
            end
            
            def load_from_file(file)
                proxy = DefinitionProxy.new
                proxy.from_file(file)
                @files[file] = proxy
                return proxy
            end

            def load_from_block(name, &block)
                proxy = DefinitionProxy.new
                proxy.instance_eval(&block)
                @files[name] = proxy
                return proxy
            end

        end
    end
end