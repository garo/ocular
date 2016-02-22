require 'singleton'
require 'yaml'

class Ocular
    class Settings
        attr_accessor :settings

        include Singleton

        def initialize()
            filename = ENV['OCULAR_SETTINGS']
            self.settings = YAML::load_file(filename)
        end

        def self.load_from_file(filename)
            @settings = YAML::load_file(filename)
        end

        def self.get(key)
            return @settings[key]
        end

    end
end
