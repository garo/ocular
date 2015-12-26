
require 'securerandom'
require 'ocular/dsl/logging'
require 'logger'

class Ocular
    module DSL
        class RunContext
            attr_accessor :run_id

            include Ocular::DSL::Logging

            def initialize
                @run_id = SecureRandom.uuid()
                @logger = Ocular::DSL::Logger.new
            end
        end
    end
end
