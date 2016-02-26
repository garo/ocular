
require 'securerandom'

class Ocular
    module DSL
        class RunContext
            attr_accessor :run_id
            attr_accessor :proxy
            attr_accessor :class_name
            attr_accessor :event_signature

            include Ocular::DSL::Logging
            include Ocular::DSL::SSH
            include Ocular::DSL::Fog
            include Ocular::DSL::Etcd

            def initialize
                @run_id = SecureRandom.uuid()
                @logger = Ocular::DSL::Logger.new
                @cleanups = []
            end

            def method_missing(method_sym, *arguments, &block)
                if self.proxy
                    self.proxy.send(method_sym, *arguments, &block)
                else
                    raise NoMethodError("undefined method `#{method_sym}` in event #{self.class_name}")
                end
            end

            def register_cleanup(&block)
                @cleanups << block
            end

            def cleanup()
                for i in @cleanups
                    i.call()
                end
            end
        end
    end
end
