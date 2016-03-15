require 'logger'
require 'rye'

class Ocular
    module DSL
        module SSH

            add_help "ssh_to(hostname)", "Returns Rye::Box ready to execute commands on host hostname"
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
