require 'singleton'
require 'yaml'
require 'ocular/utils.rb'

class Ocular
    class Settings
        attr_accessor :settings

        include Singleton

        def initialize()
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
