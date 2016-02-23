
class Ocular
    module Inputs
        class Handlers

            def initialize
                @map = Hash.new
            end

            def get(klass)
                if @map[klass]
                    return @map[klass]
                end

                @map[klass] = klass.new(::Ocular::Settings.get(:inputs))
                return @map[klass]
            end

        end
    end
end
