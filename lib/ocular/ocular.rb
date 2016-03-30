require 'ocular/logging/console_logger.rb'

$ocular_global_logger = Ocular::Logging::ConsoleLogger.new

class Ocular

    def self.logger
        return $ocular_global_logger
    end

    def self.set_global_logger(logger)
        $ocular_global_logger = logger
    end
end

require 'ocular/version'
require 'ocular/logging/logging'
require 'ocular/settings'
require 'ocular/event/eventbase'
require 'ocular/event/eventfactory'
require 'ocular/dsl/dsl'
require 'ocular/inputs/cron_input'
require 'ocular/dsl/runcontext'
require 'ocular/inputs/handlers'
require 'ocular/inputs/base'
require 'ocular/inputs/http_input'
require 'ocular/daemon'


