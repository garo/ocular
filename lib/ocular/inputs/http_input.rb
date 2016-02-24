require 'sinatra/base'
require 'puma'
require 'rack'
require 'rack/server'
require 'ocular/inputs/base.rb'

class Ocular
    module Inputs

        module HTTP

            module DSL

                def onGET(path, opts = {}, &block)
                    handler = handlers.get(::Ocular::Inputs::HTTP::Input)
                    handler.add_get(script_name, path, opts, &block)
                end

                def onPOST(path, opts = {}, &block)
                    handler = handlers.get(::Ocular::Inputs::HTTP::Input)
                    handler.add_post(script_name, path, opts, &block)
                end

            end

            class Input < ::Ocular::Inputs::Base
                DEFAULT_SETTINGS = {
                    :host => '0.0.0.0',
                    :port => 8080,
                    :verbose => false,
                    :silent => false
                }

                class SinatraApp < Sinatra::Base
                    configure do
                        set :server, :puma
                    end

                    get '/noop' do
                        puts "/check called"
                        "OK\n"
                    end
                end

                def generate_uri_from_names(script_name, path)
                    puts "generate_uri_from_names: #{script_name}, #{path}"
                    if path[0] == "/"
                        path = path[1..-1]
                    end
                    
                    if script_name && script_name != ""
                        name = script_name + "/" + path
                    else
                        name = path
                    end

                    return "/" + name
                end

                def add_get(script_name, path, options = {}, &block)
                    name = generate_uri_from_names(script_name, path)
                    puts "adding get at #{name}"
                    @app_class.get(name, options, &block)
                end

                def add_post(script_name, path, options = {}, &block)
                    name = generate_uri_from_names(script_name, path)                    
                    @app_class.post(name, options, &block)
                end

                def initialize(settings_factory)
                    settings = settings_factory[:http]

                    @settings = DEFAULT_SETTINGS.merge(settings)
                    @stopsignal = Queue.new()
                    @thread = nil

                    @app_class = Class.new(SinatraApp)

                end

                def start()
                    @app = @app_class.new
                    if @settings[:Verbose]
                      @app = Rack::CommonLogger.new(@app, STDOUT)
                    end

                    @thread = Thread.new do
                        events_hander = @settings[:Silent] ? ::Puma::Events.strings : ::Puma::Events.stdio
                        server   = ::Puma::Server.new(@app, events_hander)

                        server.add_tcp_listener @settings[:host], @settings[:port]
                        server.min_threads = 0
                        server.max_threads = 16

                        server.run
                        @stopsignal.pop
                        server.stop(true)
                    end
                end

                def stop()
                    @stopsignal << "EXIT"
                    @thread.join
                end

            end
        end
    end
end
