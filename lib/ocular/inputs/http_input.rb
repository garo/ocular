require 'puma'
require 'rack'
require 'rack/server'
require 'rack/protection'
require 'uri'

require 'ocular/inputs/base.rb'
require 'ocular/dsl/dsl.rb'
require 'ocular/dsl/runcontext.rb'

# Some of this code is copied from the excellent Sinatra Ruby web library by
# Blake Mizerany and Konstantin Haase.

class Ocular
    module Inputs

        module HTTP

            module DSL

                def onGET(path, opts = {}, &block)                    
                    handler = handlers.get(::Ocular::Inputs::HTTP::Input)
                    handler.add_get(script_name, path, opts, self, &block)
                end

                def onPOST(path, opts = {}, &block)
                    handler = handlers.get(::Ocular::Inputs::HTTP::Input)
                    handler.add_post(script_name, path, opts, self, &block)
                end

                def onDELETE(path, opts = {}, &block)
                    handler = handlers.get(::Ocular::Inputs::HTTP::Input)
                    handler.add_delete(script_name, path, opts, self, &block)
                end

                def onOPTIONS(path, opts = {}, &block)
                    handler = handlers.get(::Ocular::Inputs::HTTP::Input)
                    handler.add_options(script_name, path, opts, self, &block)
                end

            end

            module ErrorDSL
                class ClientError < ::Exception
                    def initialize(status, message)
                        @status = status
                        @message = message
                    end

                    def http_status
                        puts "http_status called: #{@status}"
                        return @status
                    end

                    def to_s
                        puts "to_s called: #{@message}"
                        return @message
                    end
                end
            end

            class Input < ::Ocular::Inputs::Base

                attr_reader :routes


                class WebRunContext < ::Ocular::DSL::RunContext
                    attr_accessor :request, :response, :params, :env

                    include ::Ocular::Inputs::HTTP::ErrorDSL

                    def initialize()
                        super(Ocular::Logging::ConsoleLogger.new) 
                        @headers = {}
                    end

                    def content_type(type)
                        @headers["Content-Type"] = type
                    end

                    def exec_wrapper(res)
                        if Fixnum === res
                            res = [res, @headers, nil]
                        end

                        if String === res
                            res = [200, @headers, res]
                        end

                        return res
                    end
                end


                URI_INSTANCE = URI::Parser.new

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

                def generate_uri_from_names(script_name, path)
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

                def add_get(script_name, path, options, proxy, &block)
                    name = generate_uri_from_names(script_name, path)
                    route('GET', name, options, proxy, &block)
                end

                def add_post(script_name, path, options, proxy, &block)
                    name = generate_uri_from_names(script_name, path)
                    route('POST', name, options, proxy, &block)
                end

                def add_delete(script_name, path, options, proxy, &block)
                    name = generate_uri_from_names(script_name, path)
                    route('DELETE', name, options, proxy, &block)
                end

                def add_options(script_name, path, options, proxy, &block)
                    name = generate_uri_from_names(script_name, path)
                    route('OPTIONS', name, options, proxy, &block)
                end

                def build_signature(pattern, keys, &block)
                    return [pattern, keys, block]
                end

                def route(verb, path, options, proxy, &block)
                    ::Ocular.logger.debug("Binding #{verb} #{path} to block #{block}")

                    eventbase = Ocular::DSL::EventBase.new(proxy, &block)
                    (proxy.events[verb] ||= {})[path] = eventbase

                    pattern, keys = compile(path)

                    (@routes[verb] ||= []) << build_signature(pattern, keys) do |context|
                        context.event_signature = [verb, path]
                        response = eventbase.exec(context)
                        environment = {
                            :path => path,
                            :options => options,
                            :request => context.request,
                            :params => context.params,
                            :env => context.env,
                            :response => response
                        }
                        context.log_cause("on#{verb}", environment)

                        response
                    end
                end

                def safe_ignore(ignore)
                    unsafe_ignore = []
                    ignore = ignore.gsub(/%[\da-fA-F]{2}/) do |hex|
                        unsafe_ignore << hex[1..2]
                        ''
                    end
                    unsafe_patterns = unsafe_ignore.map! do |unsafe|
                        chars = unsafe.split(//).map! do |char|
                            char == char.downcase ? char : char + char.downcase
                        end

                        "|(?:%[^#{chars[0]}].|%[#{chars[0]}][^#{chars[1]}])"
                    end
                    if unsafe_patterns.length > 0
                        "((?:[^#{ignore}/?#%]#{unsafe_patterns.join()})+)"
                    else
                        "([^#{ignore}/?#]+)"
                    end
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

                def encoded(char)
                    enc = URI_INSTANCE.escape(char)
                    enc = "(?:#{escaped(char, enc).join('|')})" if enc == char
                    enc = "(?:#{enc}|#{encoded('+')})" if char == " "
                    enc
                end

                def escaped(char, enc = URI_INSTANCE.escape(char))
                    [Regexp.escape(enc), URI_INSTANCE.escape(char, /./)]
                end

                def call(env)
                    dup.call!(env)
                end

                # Set or retrieve the response body. When a block is given,
                # evaluation is deferred until the body is read with #each.
                def body(context, value = nil, &block)
                    if block_given?
                        def block.each; yield(call) end
                        context.response.body = block
                    elsif value
                        # Rack 2.0 returns a Rack::File::Iterator here instead of
                        # Rack::File as it was in the previous API.
                        unless context.request.head?
                            headers(context).delete 'Content-Length'
                        end
                        context.response.body = value
                    else
                        context.response.body
                    end
                end

                def call!(env)
                    context = WebRunContext.new

                    context.request = Request.new(env)
                    context.response = Response.new
                    context.env = env
                    context.params = indifferent_params(context.request.params)

                    context.response['Content-Type'] = nil
                    invoke(context) { |context| dispatch(context) }

                    unless context.response['Content-Type']
                        context.response['Content-Type'] = "text/html"
                    end

                    context.response.finish
                end

                def dispatch(context)
                    invoke(context) do |context|
                        route!(context)
                    end

                rescue ::Exception => error
                    invoke(context) do |context|
                        handle_exception!(context, error)
                    end
                ensure
                    
                end

                def invoke(context)
                    res = catch(:halt) { yield(context) }

                    if Array === res and Fixnum === res.first
                        res = res.dup
                        status(context, res.shift)
                        body(context, res.pop)
                        headers(context, *res)
                    elsif res.respond_to? :each
                        body(context, res)
                    end
                    nil # avoid double setting the same response tuple twice
                end                

                def handle_exception!(context, error)
                    context.env['error'] = error

                    if error.respond_to? :http_status
                        context.response.status = error.http_status

                        if error.respond_to? :to_s
                            str = error.to_s
                            if !str.end_with?("\n")
                                str += "\n"
                            end
                            context.response.body = str
                        end
                    else
                        context.response.status = 500
                        puts "Internal Server Error: #{error}"
                        puts error.backtrace
                    end
                end

                def call_block(context)
                    yield(context)
                end

                def route!(context)
                    if routes = @routes[context.request.request_method]
                        routes.each do |pattern, keys, block|
                            process_route(context, pattern, keys) do |*args|
                                #env['route'] = block.instance_variable_get(:@route_name)

                                #throw :halt, context.exec(&block)
                                throw :halt, call_block(context, &block)
                            end
                        end
                    end

                    puts "Route missing"
                    raise NotFound
                end

                def process_route(context, pattern, keys, values = [])
                    route = context.request.path_info
                    route = '/' if route.empty?
                    return unless match = pattern.match(route)
                    values += match.captures.map! { |v| URI_INSTANCE.unescape(v) if v }

                    if values.any?
                        original, @params = context.params, context.params.merge('splat' => [], 'captures' => values)
                        keys.zip(values) { |k,v| Array === context.params[k] ? context.params[k] << v : context.params[k] = v if v }
                    end

                    yield(self, values)

                rescue
                    context.env['error.params'] = context.params
                    raise
                ensure
                    @params = original if original
                end                

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

                def status(context, value = nil)
                    context.response.status = value if value
                    context.response.status
                end

                def headers(context, hash = nil)
                    context.response.headers.merge! hash if hash
                    context.response.headers
                end

                def initialize(settings_factory)
                    settings = settings_factory[:http]

                    @routes = {}
                    @settings = DEFAULT_SETTINGS.merge(settings)
                    @stopsignal = Queue.new()
                    @thread = nil

                end

                def start()
                    
                    if @settings[:verbose]
                      @app = Rack::CommonLogger.new(@app, STDOUT)
                    end
                    ::Ocular.logger.debug "Puma HTTP server started with settings #{@settings}"

                    @thread = Thread.new do
                        events_hander = @settings[:silent] ? ::Puma::Events.strings : ::Puma::Events.stdio
                        server   = ::Puma::Server.new(self, events_hander)

                        server.add_tcp_listener @settings[:host], @settings[:port]
                        server.min_threads = 0
                        server.max_threads = 16

                        server.run
                        @stopsignal.pop
                        server.stop(true)
                    end

                    define_check_route()
                end

                def define_check_route
                    pattern, keys = compile("/check")

                    (@routes["GET"] ||= []) << build_signature(pattern, keys) do |context|
                        [200, "OK\n"]
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
