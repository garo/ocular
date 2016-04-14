
require 'ocular/inputs/base.rb'
require 'ocular/dsl/dsl.rb'
require 'ocular/dsl/runcontext.rb'
require 'bunny'

class Ocular
    module Inputs

        module RabbitMQ

            module DSL

                #add_event_help "cron.in(rule)", "Schedule event to be executed in 'rule'. eg: '1m'"
                def rabbitmq()
                    handler = handlers.get(::Ocular::Inputs::RabbitMQ::Input)
                    return Input::DSLProxy.new(self, handler, logger)
                end

            end

            class Input < ::Ocular::Inputs::Base

                attr_reader :routes
                attr_reader :conn
                attr_reader :settings

                def initialize(settings_factory)
                    @settings = settings_factory[:rabbitmq]

                    ::Ocular.logger.debug "Starting RabbitMQ input"

                    @conn = Bunny.new
                    @conn.start
                end

                def start()

                end

                def stop()
                end

                class RabbitMQRunContext < ::Ocular::DSL::RunContext
                    attr_accessor :delivery_info, :metadata, :payload

                    def initialize(logger)
                        super(logger)
                    end
                end


                class DSLProxy                    
                    def initialize(proxy, handler, logger)
                        @proxy = proxy
                        @handler = handler
                        @logger = logger
                    end

                    def subscribe(queue, &block)
                        eventbase = Ocular::DSL::EventBase.new(@proxy, &block)
                        ::Ocular.logger.debug "rabbitmq.subscribe to# #{queue} for block #{block}"

                        ch = @handler.conn.create_channel
                        q  = ch.queue(queue)

                        q.subscribe do |delivery_info, metadata, payload|
                            context = RabbitMQRunContext.new(@logger)
                            context.log_cause("rabbitmq.subscribe(#{queue})", {:delivery_info => delivery_info, :metadata => metadata, :payload => payload})
                            context.delivery_info = delivery_info
                            context.metadata = metadata
                            context.payload = payload
                            eventbase.exec(context)
                        end

                        id = queue + "-" + block.to_s

                        @proxy.events[id] = eventbase

                        return id
                    end

                end

            end
        end
    end
end
