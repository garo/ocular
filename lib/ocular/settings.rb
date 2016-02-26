require 'singleton'
require 'yaml'
require 'ocular/utils.rb'

class Ocular
    class Settings
        attr_accessor :settings

        include Singleton

        def initialize()
        end

        def self.find_settings_file_from_system(filename)
            if ENV['OCULAR_SETTINGS'] != nil
                filename = File.expand_path(ENV['OCULAR_SETTINGS'])
            end

            if !filename or !File.exists?(filename)
                filename = File.expand_path('~/.ocular.yaml')
            end

            if !filename or !File.exists?(filename)
                filename = File.expand_path('/etc/ocular.yaml')
            end

            return filename
        end

        def self.load_from_file(filename)
            #puts "Loaded settings from #{filename}"
            @settings = ::Ocular::deep_symbolize(YAML::load_file(filename))
        end

        def self.get(key)
            return @settings[key]
        end

    end
end
