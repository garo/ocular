require 'logger'
require 'etcd'

class Ocular
    module DSL
        module Orbit

            add_help "orbit", "Returns OrbitFunctions instance for accessing orbit control data"

            class OrbitFunctions
                def initialize(etcd)
                    @etcd = etcd
                end

                add_help "orbit::get_service_endpoints(service_name)", "Returns an array of ips running service_name"
                def get_service_endpoints(service_name)
                    orbit_endpoints = []
                    begin
                        endpoints = @etcd.get("/orbit/services/#{service_name}/endpoints").node.children
                        pp endpoints
                        endpoints.each do |node|
                          ip = node.key.match(/.*endpoints.(.+?):.+/).captures[0]
                          orbit_endpoints << ip
                        end
                    rescue ::Etcd::KeyNotFound
                        return []
                    end

                    return orbit_endpoints
                end
            end


            def orbit()
                return OrbitFunctions.new(etcd())
            end
        end

    end
end
