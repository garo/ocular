
class Ocular
    module Logging
        # Logging severity.
        module Severity
            LABELS = %w(DEBUG INFO WARN ERROR FATAL ANY).each(&:freeze).freeze

            # Low-level information, mostly for developers.
            DEBUG = 0
            # Generic (useful) information about system operation.
            INFO = 1
            # A warning.
            WARN = 2
            # A handleable error condition.
            ERROR = 3
            # An unhandleable error that results in a program crash.
            FATAL = 4
            # An unknown message that should always be logged.
            UNKNOWN = 5
        end
    end
end
