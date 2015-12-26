require 'ocular/dsl/dsl.rb'

class Ocular
    class EventFactory

        def initialize
            @files = {}
        end
        
        def load_from_file(file)
            proxy = Ocular::DSL::DefinitionProxy.new
            proxy.from_file(file)
            @files[file] = proxy
            return proxy
        end

        def load_from_block(name, &block)
            proxy = Ocular::DSL::DefinitionProxy.new
            proxy.instance_eval(&block)
            @files[name] = proxy
            return proxy
        end

    end
end