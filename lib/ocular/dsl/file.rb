require 'logger'
require 'net/http'
require 'cgi'

class Ocular
    module DSL
        module File

            def getfullpath(file)
                return dirname + file
            end

        end

    end
end
