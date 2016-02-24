require 'logger'
require 'rye'

class Ocular
    module DSL
        module SSH

            def ssh_to(hostname)
                settings = ::Ocular::Settings::get(:ssh)
                settings[:password_prompt] = false
                settings[:safe] = false

                rbox = ::Rye::Box.new(hostname, settings)
                return rbox
            end

        end

    end
end
