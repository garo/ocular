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

        def load_script_files()
            files = self.get_script_files(@root_path)
            for file in files
                @eventfactory.load_from_file(file, file[@root_path.length+1..-1])
            end
        end

        def start_input_handlers()
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
