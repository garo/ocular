require 'logger'
require 'pg'

class Ocular
    module DSL
        module Psql

            add_help "psql", "Returns a PostgreSQL client instance"

            def psql(cluster = :default)
                datasources = ::Ocular::Settings::get(:datasources)                
                if !datasources or !datasources[:psql]
                    raise "No psql client settings"
                end
                connection_string = datasources[:psql][cluster]

                return ::PG.connect(connection_string)
            end

        end

    end
end
