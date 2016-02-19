require 'ocular/event/eventbase.rb'

class Ocular
    module Event
        class DefinitionProxy
          attr_accessor :events
          attr_accessor :klass_name

          def initialize(klass_name)
            self.klass_name = klass_name
            @events = []
            @logger = Ocular::DSL::Logger.new
          end

          include Ocular::Mixin::FromFile
          include Ocular::DSL::Logging

          def onEvent(factory_class, &block)
            eventbase = Ocular::DSL::EventBase.new(&block)
            eventbase.proxy = self
            @events << eventbase
          end
        end

        class EventFactory

            def initialize
                @files = {}
            end
            
            def load_from_file(file)
                proxy = DefinitionProxy.new(file)
                proxy.from_file(file)
                @files[file] = proxy
                return proxy
            end

            def load_from_block(name, &block)
                proxy = DefinitionProxy.new(name)
                proxy.instance_eval(&block)
                @files[name] = proxy
                return proxy
            end

        end
    end
end