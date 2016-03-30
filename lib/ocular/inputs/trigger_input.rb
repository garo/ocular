
require 'ocular/inputs/base.rb'
require 'ocular/dsl/dsl.rb'
require 'ocular/dsl/runcontext.rb'
require 'rufus/scheduler'

class Ocular
    module Inputs

        module Trigger

            module DSL

                def onTrigger(evaluator, &block)
                    handler = handlers.get(::Ocular::Inputs::Trigger::Input)

                    eventbase = Ocular::DSL::EventBase.new(@proxy, &block)

                    id = handler.add_evaluator(evaluator) do
                        context = ::Ocular::DSL::RunContext.new(@logger)
                        eventbase.exec(context)
                    end

                    @proxy.events[id] = eventbase

                    return id
                end

            end

            class Input < ::Ocular::Inputs::Base

                attr_reader :routes
                attr_reader :scheduler

                def initialize(settings_factory)
                    settings = settings_factory[:http]
                    @scheduler = ::Rufus::Scheduler.new
                end

                def start()

                end

                def add_evaluator(evaluator, &block)

                end

                def stop()
                    @scheduler.shutdown
                end
            end
        end
    end
end
