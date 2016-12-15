require 'logger'
require 'mongo'

class Ocular
    module DSL
        module Mongo

            add_help "mongo", "Returns a mongodb client instance"

            def mongo(cluster = :default)
                datasources = ::Ocular::Settings::get(:datasources)                
                if !datasources or !datasources[:mongo]
                    raise "No mongodb client settings"
                end
                connection_string = datasources[:mongo][cluster]

                return ::Mongo::Client.new(connection_string)
            end

        end

    end
end
