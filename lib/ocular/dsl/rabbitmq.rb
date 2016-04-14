require 'logger'
require 'etcd'

class Ocular
    module DSL
        module RabbitMQ

            add_help "amqp", "Returns a channel to RabbitMQ broker"

            def amqp()
                datasources = ::Ocular::Settings::get(:datasources)
                if !datasources or !datasources[:rabbitmq]
                    raise "No rabbitmq client settings"
                end
                settings = datasources[:rabbitmq] || {}
                conn = Bunny.new(settings[:url] || nil)
                conn.start

                return conn.create_channel
            end

        end

    end
end
