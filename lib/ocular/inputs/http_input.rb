require 'sinatra/base'
require 'puma'
require 'rack'
require 'rack/server'
require 'rack/protection'

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

                class Request < Rack::Request
                    HEADER_PARAM = /\s*[\w.]+=(?:[\w.]+|"(?:[^"\\]|\\.)*")?\s*/
                    HEADER_VALUE_WITH_PARAMS = /(?:(?:\w+|\*)\/(?:\w+(?:\.|\-|\+)?|\*)*)\s*(?:;#{HEADER_PARAM})*/

                    # Returns an array of acceptable media types for the response
                    def accept
                        @env['sinatra.accept'] ||= begin
                        if @env.include? 'HTTP_ACCEPT' and @env['HTTP_ACCEPT'].to_s != ''
                            @env['HTTP_ACCEPT'].to_s.scan(HEADER_VALUE_WITH_PARAMS).
                                map! { |e| AcceptEntry.new(e) }.sort
                            else
                                [AcceptEntry.new('*/*')]
                            end
                        end
                    end

                    def accept?(type)
                        preferred_type(type).to_s.include?(type)
                    end

                    def preferred_type(*types)
                        accepts = accept # just evaluate once
                        return accepts.first if types.empty?
                        types.flatten!
                        return types.first if accepts.empty?
                        accepts.detect do |pattern|
                            type = types.detect { |t| File.fnmatch(pattern, t) }
                            return type if type
                        end
                    end

                    alias secure? ssl?

                    def forwarded?
                        @env.include? "HTTP_X_FORWARDED_HOST"
                    end

                    def safe?
                        get? or head? or options? or trace?
                    end

                    def idempotent?
                        safe? or put? or delete? or link? or unlink?
                    end

                    def link?
                        request_method == "LINK"
                    end

                    def unlink?
                        request_method == "UNLINK"
                    end

                    private

                    class AcceptEntry
                        attr_accessor :params
                        attr_reader :entry

                        def initialize(entry)
                            params = entry.scan(HEADER_PARAM).map! do |s|
                                key, value = s.strip.split('=', 2)
                                value = value[1..-2].gsub(/\\(.)/, '\1') if value.start_with?('"')
                                [key, value]
                            end

                            @entry  = entry
                            @type   = entry[/[^;]+/].delete(' ')
                            @params = Hash[params]
                            @q      = @params.delete('q') { 1.0 }.to_f
                        end

                        def <=>(other)
                            other.priority <=> self.priority
                        end

                        def priority
                            # We sort in descending order; better matches should be higher.
                            [ @q, -@type.count('*'), @params.size ]
                        end

                        def to_str
                            @type
                        end

                        def to_s(full = false)
                            full ? entry : to_str
                        end

                        def respond_to?(*args)
                            super or to_str.respond_to?(*args)
                        end

                        def method_missing(*args, &block)
                            to_str.send(*args, &block)
                        end
                    end
                end

                class NotFound < NameError #:nodoc:
                    def http_status; 404 end
                end

                # The response object. See Rack::Response and Rack::Response::Helpers for
                # more info:
                # http://rubydoc.info/github/rack/rack/master/Rack/Response
                # http://rubydoc.info/github/rack/rack/master/Rack/Response/Helpers
                class Response < Rack::Response
                    DROP_BODY_RESPONSES = [204, 205, 304]
                    def initialize(*)
                        super
                        headers['Content-Type'] ||= 'text/html'
                    end

                    def body=(value)
                        value = value.body while Rack::Response === value
                        @body = String === value ? [value.to_str] : value
                    end

                    def each
                        block_given? ? super : enum_for(:each)
                    end

                    def finish
                        result = body

                        if drop_content_info?
                            headers.delete "Content-Length"
                            headers.delete "Content-Type"
                        end

                        if drop_body?
                            close
                            result = []
                        end

                        if calculate_content_length?
                            # if some other code has already set Content-Length, don't muck with it
                            # currently, this would be the static file-handler
                            headers["Content-Length"] = body.inject(0) { |l, p| l + p.bytesize }.to_s
                        end

                        [status.to_i, headers, result]
                    end

                    private

                    def calculate_content_length?
                        headers["Content-Type"] and not headers["Content-Length"] and Array === body
                    end

                    def drop_content_info?
                        status.to_i / 100 == 1 or drop_body?
                    end

                    def drop_body?
                        DROP_BODY_RESPONSES.include?(status.to_i)
                    end
                end


                class ServerBase
                    class << self

                        attr_reader :routes

                        def reset!
                            @routes = {}
                        end

                        def inherited(subclass)
                            subclass.reset!
                        end

                        def post(path, opts = {}, &block)   route 'POST',   path, opts, &block end
                        def get(path, opts = {}, &block)    route 'GET',    path, opts, &block end

                        def route(verb, path, options = {}, &block)
                            puts "Defined route #{verb} #{path}"

                            signature = compile!(verb, path, block, options)
                            (@routes[verb] ||= []) << signature
                        end

                        def generate_method(method_name, &block)
                            method_name = method_name.to_sym
                            define_method(method_name, &block)
                            method = instance_method method_name
                            remove_method method_name
                            method
                        end


                        def compile!(verb, path, block, options = {})
                            method_name = "#{verb} #{path}"
                            unbound_method = generate_method(method_name, &block)
                            pattern, keys = compile path

                            wrapper = block.arity != 0 ?
                                proc { |a, p| unbound_method.bind(a).call(*p) } :
                                proc { |a, p| unbound_method.bind(a).call }

                            wrapper.instance_variable_set(:@route_name, method_name)

                            puts "Compiled: #{pattern} #{keys} #{wrapper}"
                            [ pattern, keys, wrapper ]
                        end

                        def compile(path)
                            if path.respond_to? :to_str
                                keys = []

                                # Split the path into pieces in between forward slashes.
                                # A negative number is given as the second argument of path.split
                                # because with this number, the method does not ignore / at the end
                                # and appends an empty string at the end of the return value.
                                #
                                segments = path.split('/', -1).map! do |segment|
                                    ignore = []

                                    # Special character handling.
                                    #
                                    pattern = segment.to_str.gsub(/[^\?\%\\\/\:\*\w]|:(?!\w)/) do |c|
                                        ignore << escaped(c).join if c.match(/[\.@]/)
                                        patt = encoded(c)
                                        patt.gsub(/%[\da-fA-F]{2}/) do |match|
                                            match.split(//).map! { |char| char == char.downcase ? char : "[#{char}#{char.downcase}]" }.join
                                        end
                                    end

                                    ignore = ignore.uniq.join

                                    # Key handling.
                                    #
                                    pattern.gsub(/((:\w+)|\*)/) do |match|
                                        if match == "*"
                                            keys << 'splat'
                                            "(.*?)"
                                        else
                                            keys << $2[1..-1]
                                        ignore_pattern = safe_ignore(ignore)

                                        ignore_pattern
                                        end
                                    end
                                end

                                # Special case handling.
                                #
                                if last_segment = segments[-1] and last_segment.match(/\[\^\\\./)
                                    parts = last_segment.rpartition(/\[\^\\\./)
                                    parts[1] = '[^'
                                    segments[-1] = parts.join
                                end
                                [/\A#{segments.join('/')}\z/, keys]
                            elsif path.respond_to?(:keys) && path.respond_to?(:match)
                                [path, path.keys]
                            elsif path.respond_to?(:names) && path.respond_to?(:match)
                                [path, path.names]
                            elsif path.respond_to? :match
                                [path, []]
                            else
                                raise TypeError, path
                            end
                        end

                    end # end of class << self

                    attr_accessor :env, :request, :response

                    # Creates a Hash with indifferent access.
                    def indifferent_hash
                        Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
                    end


                    def indifferent_params(object)
                        case object
                        when Hash
                            new_hash = indifferent_hash
                            object.each { |key, value| new_hash[key] = indifferent_params(value) }
                            new_hash
                        when Array
                            object.map { |item| indifferent_params(item) }
                        else
                            object
                        end
                    end

                    def status(value = nil)
                        response.status = value if value
                        response.status
                    end

                    def headers(hash = nil)
                        response.headers.merge! hash if hash
                        response.headers
                    end

                    def invoke
                        res = catch(:halt) { yield }

                        res = [res] if Fixnum === res or String === res
                        if Array === res and Fixnum === res.first
                            res = res.dup
                            status(res.shift)
                            body(res.pop)
                            headers(*res)
                        elsif res.respond_to? :each
                            body res
                        end
                        nil # avoid double setting the same response tuple twice
                    end

                    def call(env)
                        puts "WebServer: call(#{env["PATH_INFO"]})"
                        dup.call!(env)
                    end

                    # Set or retrieve the response body. When a block is given,
                    # evaluation is deferred until the body is read with #each.
                    def body(value = nil, &block)
                        if block_given?
                            def block.each; yield(call) end
                            response.body = block
                        elsif value
                            # Rack 2.0 returns a Rack::File::Iterator here instead of
                            # Rack::File as it was in the previous API.
                            unless request.head?
                                headers.delete 'Content-Length'
                            end
                            response.body = value
                        else
                            response.body
                        end
                    end


                    def call!(env)
                        @env = env
                        @request = Request.new(env)
                        @response = Response.new
                        @params = indifferent_params(@request.params)

                        @response['Content-Type'] = nil
                        invoke { dispatch! }

                        unless @response['Content-Type']
                            @response['Content-Type'] = "text/html"
                        end

                        puts "response:"
                        pp @response           

                        @response.finish
                    end

                    def self.settings
                        self
                    end

                    def settings
                        self.class.settings
                    end

                    def dispatch!
                        invoke do
                            route!
                        end
                    rescue ::Exception => error
                        puts "Error while invoking route: #{error}"
                    ensure
                        
                    end

                    def route_eval
                        puts "Evaluating route"
                        throw :halt, yield
                    end

                    def route!(base = settings, pass_block = nil)
                        if routes = base.routes[@request.request_method]
                            routes.each do |pattern, keys, block|
                                pass_block = process_route(pattern, keys) do |*args|
                                    env['route'] = block.instance_variable_get(:@route_name)
                                    route_eval { block[*args] }
                                end
                            end
                        end

                        puts "Route missing"
                        raise NotFound
                    end

                    def process_route(pattern, keys, block = nil, values = [])
                        route = @request.path_info
                        puts "processing route. pattern: #{pattern} against #{route}"
                        route = '/' if route.empty? and not settings.empty_path_info?
                        return unless match = pattern.match(route)
                        puts "match!"
                        values += match.captures.map! { |v| force_encoding URI_INSTANCE.unescape(v) if v }

                        if values.any?
                            original, @params = params, params.merge('splat' => [], 'captures' => values)
                            keys.zip(values) { |k,v| Array === @params[k] ? @params[k] << v : @params[k] = v if v }
                        end

                        catch(:pass) do
                            block ? block[self, values] : yield(self, values)
                        end

                    rescue
                        @env['sinatra.error.params'] = @params
                        raise
                    ensure
                        @params = original if original
                    end

                end

                class WebServer < ServerBase

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

                    @app_class = Class.new(WebServer)

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
