require 'ocular/mixin/from_file'

class Ocular
  module DSL

    class DefinitionProxy
      attr_accessor :events

      def initialize
        @events = []
      end

      include Ocular::Mixin::FromFile

      def onEvent(factory_class, &block)
        eventbase = EventBase.new(&block)
        @events << eventbase
      end
    end

    class EventBase
      def initialize(&block)
        @callback = block
      end

      def exec
        self.instance_eval(&@callback)
      end
    end
  end
end

