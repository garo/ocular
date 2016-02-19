require 'ocular/mixin/from_file'

class Ocular
    module DSL

        class EventBase
            def initialize(&block)
              @callback = block
            end

            def exec(run_context)
                run_context.instance_eval(&@callback)
            end
        end
    end
end

