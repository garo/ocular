require 'ocular/mixin/from_file'
require 'ocular/dsl/fog'
require 'ocular/dsl/ssh'
require 'ocular/dsl/logging'

class Ocular
    module DSL

        class EventBase
            include Ocular::DSL::SSH
            include Ocular::DSL::Fog
            include Ocular::DSL::Logging

            attr_accessor :proxy


            def initialize(&block)
              @callback = block
            end

            def exec(run_context)
                puts "eventbase exec is called for #{self.proxy} with #{@callback}"
                run_context.proxy = self.proxy
                run_context.instance_eval(&@callback)
            end

        end
    end
end

