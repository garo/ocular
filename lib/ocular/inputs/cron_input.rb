
require 'ocular/inputs/base.rb'
require 'ocular/dsl/dsl.rb'
require 'ocular/dsl/runcontext.rb'
require 'rufus/scheduler'

class Ocular
    module Inputs

        module Cron

            module DSL

                add_event_help "cron.in(rule)", "Schedule event to be executed in 'rule'. eg: '1m'"
                add_event_help "cron.at(rule)", "Schedule event to be executed at 'rule'. eg: '2030/12/12 23:30:00'"
                add_event_help "cron.every(rule)", "Schedule event to be executed every 'rule'. eg: '15m'"
                add_event_help "cron.cron(rule)", "Schedule event with cron syntax. eg: '5 0 * * *'"
                def cron()
                    handler = handlers.get(::Ocular::Inputs::Cron::Input)
                    return Input::DSLProxy.new(self, handler, logger)
                end

            end

            class Input < ::Ocular::Inputs::Base

                attr_reader :routes
                attr_reader :scheduler

                def initialize(settings_factory)
                    settings = settings_factory[:http]

                    @scheduler = ::Rufus::Scheduler.new
                    ::Ocular.logger.debug "Starting Rufus cron scheduler"
                end

                def start()

                end

                def stop()
                    @scheduler.shutdown
                end

                class DSLProxy
                    def initialize(proxy, handler, logger)
                        @proxy = proxy
                        @handler = handler
                        @logger = logger
                    end

                    def in(rule, &block)
                        eventbase = Ocular::DSL::EventBase.new(@proxy, &block)
                        ::Ocular.logger.debug "Scheduling cron.in(#{rule}) for block #{block}"

                        id = @handler.scheduler.in(rule, :overlap => false) do
                            context = ::Ocular::DSL::RunContext.new(@logger)
                            context.log_cause("cron.in", {:rule => rule})
                            eventbase.exec(context)
                        end

                        @proxy.events[id] = eventbase

                        return id
                    end

                    def at(rule, &block)
                        eventbase = Ocular::DSL::EventBase.new(@proxy, &block)
                        ::Ocular.logger.debug "Scheduling cron.at(#{rule}) for block #{block}"

                        id = @handler.scheduler.at(rule, :overlap => false) do
                            context = ::Ocular::DSL::RunContext.new(@logger)
                            context.log_cause("cron.at", {:rule => rule})
                            eventbase.exec(context)
                        end

                        @proxy.events[id] = eventbase

                        return id
                    end

                    def every(rule, &block)
                        eventbase = Ocular::DSL::EventBase.new(@proxy, &block)
                        ::Ocular.logger.debug "Scheduling cron.every(#{rule}) for block #{block}"

                        id = @handler.scheduler.every(rule, :overlap => false) do
                            context = ::Ocular::DSL::RunContext.new(@logger)
                            context.log_cause("cron.every", {:rule => rule})
                            eventbase.exec(context)
                        end

                        @proxy.events[id] = eventbase

                        return id
                    end

                    def cron(rule, &block)
                        eventbase = Ocular::DSL::EventBase.new(@proxy, &block)
                        ::Ocular.logger.debug "Scheduling cron.cron(#{rule}) for block #{block}"

                        id = @handler.scheduler.cron(rule, :overlap => false) do
                            context = ::Ocular::DSL::RunContext.new(@logger)
                            context.log_cause("cron.cron", {:rule => rule})
                            eventbase.exec(context)
                        end

                        @proxy.events[id] = eventbase

                        return id
                    end
                end

            end
        end
    end
end
