require 'ocular/utils.rb'
require 'pp'

class Ocular
    class Daemon

        attr_accessor :eventfactory

        def initialize(root_path)

            @root_path = root_path
            @eventfactory = ::Ocular::Event::EventFactory.new
        end

        def get_script_files(root)
            return Dir::glob("#{root}/**/*.rb")
        end

        def get_name_from_file(filename)

            # -4 will strip the ".rb" away from the end
            name = filename[@root_path.length..-4]

            # If root_path is empty then we need to strip the '/' from the beginning
            if name[0] == '/'
                name = name[1..-1]
            end

            return name
        end

        def load_script_files()
            files = self.get_script_files(@root_path)
            for file in files
                @eventfactory.load_from_file(file, get_name_from_file(file))
            end
        end

        def start_input_handlers()
            puts "derp"
            @eventfactory.start_input_handlers()
        end

        def stop_input_handlers()
            @eventfactory.stop_input_handlers()
        end

        def wait()
            while true
                begin
                    sleep 60
                rescue Interrupt
                    stop_input_handlers()
                    puts "\nGoing to exit"
                    return
                end
            end
        end
    end
end
