require 'logger'
require 'fog'

class Ocular
    module DSL
        module Fog
            @@__aws_instance = nil

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

            def autoscaling()
                return ::Fog::AWS::AutoScaling.new({
                    :aws_access_key_id => ::Ocular::Settings::get(:aws)[:aws_access_key_id],
                    :aws_secret_access_key => ::Ocular::Settings::get(:aws)[:aws_secret_access_key]
                    })
            end

        end

    end
end
