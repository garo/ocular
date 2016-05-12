require 'logger'
require 'etcd'
require 'pp'

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

            def ttl_lock(key, ttl:10)
                id = @run_id
                if !id
                    id = Process.pid.to_s
                    Socket.ip_address_list.each do |addr|
                        next if addr.ip_address == "127.0.0.1"
                        next if addr.ip_address.start_with?("::1")
                        next if addr.ip_address.start_with?("fe80::1")
                        id += "-" + addr.ip_address
                    end
                end

                client = etcd()

                if locked?(key)
                    return nil
                end

                begin
                    client.create("/ocular/locks/#{key}", value: id, ttl: ttl)
                rescue ::Etcd::NodeExist => e
                    return nil
                end
            end

            def unlock(key)
                client = etcd()
                begin
                    client.delete("/ocular/locks/#{key}")
                rescue ::Etcd::KeyNotFound

                end
                return true
            end

            def locked?(key)
                client = etcd()
                begin
                    client.get("/ocular/locks/#{key}")
                    return true # Key was found, so somebody else has the lock
                rescue ::Etcd::KeyNotFound => e
                    return false
                end
            end

        end

    end
end
