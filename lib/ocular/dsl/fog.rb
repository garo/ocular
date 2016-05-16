require 'logger'
require 'fog'

class Ocular
    module DSL
        module Fog
            @@__aws_instance = nil

            add_help "aws", "Returns Fog::Compute instance"
            def aws()
                if @@__aws_instance
                    return @@__aws_instance
                end
                
                @@__aws_instance = ::Fog::Compute.new({
                    :provider => 'AWS',
                    :aws_access_key_id => ::Ocular::Settings::get(:aws)[:aws_access_key_id],
                    :aws_secret_access_key => ::Ocular::Settings::get(:aws)[:aws_secret_access_key]
                    })

                return @@__aws_instance
            end

            add_help "autoscaling", "Returns Fog::AWS::AutoScaling instance"
            def autoscaling()
                return ::Fog::AWS::AutoScaling.new({
                    :aws_access_key_id => ::Ocular::Settings::get(:aws)[:aws_access_key_id],
                    :aws_secret_access_key => ::Ocular::Settings::get(:aws)[:aws_secret_access_key]
                    })
            end


            add_help "find_servers_in_autoscaling_groups(substring)", "Returns instances in an autoscaling group which name matches substring"
            def find_servers_in_autoscaling_groups(substring)
                instances = []
                for group in autoscaling.groups
                    if group.id.include?(substring)
                        for i in group.instances
                            instances << aws.servers.get(i.id)
                        end
                    end
                end

                return instances
            end

            add_help "find_server_by_ip", "Returns Fog::Compute::AWS::Server or nil"
            def find_server_by_ip(ip)
                ret = aws().servers.all("private-ip-address" => ip)
                if ret.length > 1
                    raise "Too many matching servers by just one ip #{ip}"
                end
                if ret.length == 0
                    return nil
                end
                return ret.first
            end

            add_help "find_server_by_id", "Returns Fog::Compute::AWS::Server or nil"
            def find_server_by_id(id)
                ret = aws().servers.all("instance-id" => id)
                if ret.length > 1
                    raise "Too many matching servers by just one ip #{ip}"
                end
                if ret.length == 0
                    return nil
                end
                return ret.first
            end

        end

    end
end
