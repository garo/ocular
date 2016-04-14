require 'logger'
require 'mysql2'

class Ocular
    module DSL
        module MySQL

            add_help "mysql", "Returns a mysql client instance"

            def mysql()
                datasources = ::Ocular::Settings::get(:datasources)                
                if !datasources or !datasources[:mysql]
                    raise "No mysql client settings"
                end
                settings = datasources[:mysql] || {}
                return Mysql2::Client.new(
                    host: (settings[:host] || "localhost"),
                    port: (settings[:port] || 3306),
                    username: (settings[:username] || nil),
                    password: (settings[:password] || nil),
                    database: (settings[:database] || "ocular")
                    )
            end

        end

    end
end
