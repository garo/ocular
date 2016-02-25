
require 'securerandom'

class Ocular
    module DSL
        class RunContext
            attr_accessor :run_id
            attr_accessor :proxy
            attr_accessor :class_name

            include Ocular::DSL::Logging
            include Ocular::DSL::SSH

            def initialize
                @run_id = SecureRandom.uuid()
                @logger = Ocular::DSL::Logger.new
            end

            def method_missing(method_sym, *arguments, &block)
                if self.proxy
                    self.proxy.send(method_sym, *arguments, &block)
                else
                    raise NoMethodError("undefined method `#{method_sym}` in event #{self.class_name}")
                end
            end

        end
    end
end
