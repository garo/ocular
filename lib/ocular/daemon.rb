require 'ocular/utils.rb'
require 'pp'

class Ocular
    class Daemon

        attr_accessor :eventfactory

        def initialize(filename, root_path)
            if !filename and ENV['OCULAR_SETTINGS'] != nil
                filename = File.expand_path(ENV['OCULAR_SETTINGS'])
            end

            if !filename or !File.exists?(filename)
                filename = File.expand_path('~/.ocular.yaml')
            end

            if !filename or !File.exists?(filename)
                filename = File.expand_path('/etc/ocular.yaml')
            end

            @root_path = root_path
            Ocular::Settings.load_from_file(filename)
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
    end
end
