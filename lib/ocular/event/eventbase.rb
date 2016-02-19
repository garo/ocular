require 'ocular/mixin/from_file'
require 'ocular/dsl/ssh'
require 'ocular/dsl/logging'

class Ocular
    module DSL

        class EventBase
            include Ocular::DSL::SSH
            include Ocular::DSL::Logging


            def initialize(&block)
              @callback = block
            end

            def exec(run_context)
                puts "Running #{run_context}"
                run_context.instance_eval(&@callback)
            end

        end
    end
end

