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

                current_lock = locked?(key)

                if current_lock != id and current_lock != nil
                    return nil # Somebody else has lock, can't lock by ourself
                end

                if current_lock == id and current_lock != nil
                    begin
                        client.test_and_set("/ocular/locks/#{key}", value: id, prevValue: id, ttl: ttl)
                        return id
                    rescue ::Etcd::NodeExist => e
                        return nil
                    end

                else
                    begin
                        client.create("/ocular/locks/#{key}", value: id, ttl: ttl)
                        return id
                    rescue ::Etcd::NodeExist => e
                        return nil
                    end
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
                    ret = client.get("/ocular/locks/#{key}")
                    if ret.node and ret.node.expiration == nil
                        warn("Key #{key} has been locked permanently with value '#{ret.node.value}'!")
                    end
                    return ret.node.value # Key is locked
                rescue ::Etcd::KeyNotFound => e
                    return nil
                end
            end

        end

    end
end
