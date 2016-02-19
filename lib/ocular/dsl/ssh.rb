require 'logger'
require 'rye'

class Ocular
    module DSL
        module SSH

            def ssh_to(hostname)
                rbox = ::Rye::Box.new(hostname, :safe => false, :password_prompt => false)
                return rbox
            end

        end

    end
end
