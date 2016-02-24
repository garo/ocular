require 'pp'

class Ocular
    module Inputs
        class Handlers

            def initialize
                @handlers = Hash.new
            end

            def get(klass)
                if @handlers[klass]
                    return @handlers[klass]
                end

                @handlers[klass] = klass.new(::Ocular::Settings.get(:inputs))
                return @handlers[klass]
            end

            def start()
                @handlers.each do |name, handler|
                    handler.start()
                end
            end

            def stop()
                @handlers.each do |name, handler|
                    handler.stop()
                end
            end            
        end
    end
end