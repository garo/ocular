require 'logger'
require 'etcd'

class Ocular
    module DSL
        module Etcd
            @@__etcd_instance = nil

            add_help "etcd", "Returns an etcd client instance"

            def etcd()
                if @@__etcd_instance
                    return @@__etcd_instance
                end


                datasources = ::Ocular::Settings::get(:datasources)
                if !datasources
                    raise "No etcd client settings"
                end
                settings = datasources[:etcd] || {}
                @@__etcd_instance = ::Etcd.client(
                    host: (settings[:host] || "localhost"),
                    port: (settings[:port] || 2379),
                    user_name: (settings[:user_name] || nil),
                    password: (settings[:password] || nil),
                    )

                return @@__etcd_instance
            end

        end

    end
end
