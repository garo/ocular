require 'ocular/mixin/from_file'
require 'ocular/dsl/logging'
require 'time'

class Ocular
    module DSL

        class EventBase

            class Results
                attr_accessor :response
                attr_accessor :error
            end

            attr_accessor :proxy, :last_run

            def initialize(proxy, &block)
                @callback = block
                @proxy = proxy
            end

            def exec(context, do_fork = self.proxy.do_fork)
                start = Time.now
                begin
                    context.proxy = self.proxy
                    if do_fork
                        return exec_fork(context)
                    else
                        return exec_nofork(context)
                    end
                ensure
                    context.log_timing("execution_time", start)
                    @last_run = context
                end
            end

            def exec_fork(context)
                reader, writer = IO::pipe
                child_pid = fork do
                    reader.close
                    r = Results.new

                    begin
                        r.response = __call(context, @callback)
                    rescue Exception => error
                        r.error = error
                    end

                    begin
                        Marshal.dump(r, writer)
                    rescue TypeError => e
                        ::Ocular.logger.error "TypeError when trying to marshal event handler return value. Reason: #{e}"
                        ::Ocular.logger.error "This is usually because you forgot that the last function return value is returned from the handler function. The current type of the returned value is #{r.response.class}. Please make sure your handler returns a proper value which doesn't reference any sockets or otherwise complex unserializable objects."
                        ::Ocular.logger.error "The value of the returned value is :#{r.response.pretty_inspect}"
                    end
                    writer.close
                end
                writer.close

                data = reader.read
                r = Marshal.load(data)
                reader.close
                Process.wait(child_pid)

                if r.error
                    raise r.error
                end
                return r.response
            end

            def exec_nofork(context)
                return __call(context, @callback)
            end

            def __call(context, callback)
                # we use this trickery to workaround the LocalJumpError so that we can use return
                context.define_singleton_method(:_, &callback)
                p = context.method(:_).to_proc

                reply = p.call()
                if context.respond_to?(:exec_wrapper)
                    return context.exec_wrapper(reply)
                else
                    return reply
                end
            end

        end
    end
end

