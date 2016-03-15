require 'logger'
require 'etcd'

class Ocular
    module DSL
        module Orbit

            class OrbitFunctions
                def initialize(etcd)
                    @etcd = etcd
                end

                def get_service_endpoints(service_name)
                    orbit_endpoints = []
                    endpoints = @etcd.get("/orbit/services/#{service_name}/endpoints").node.children
                    endpoints.each do |node|
                      ip = node.key.match(/.*endpoints.(.+?):.+/).captures[0]
                      orbit_endpoints << ip
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
