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

                settings = ::Ocular::Settings::get(:inputs)[:etcd] || {}
                @@__etcd_instance = ::Etcd.client(
                    host: (settings[:host] || "localhost"),
                    port: (settings[:port] || 2379),
                    usern_name: (settings[:port] || nil),
                    password: (settings[:port] || nil),
                    )

                return @@__etcd_instance
            end

        end

    end
end
