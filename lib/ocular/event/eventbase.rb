require 'ocular/mixin/from_file'
require 'ocular/dsl/fog'
require 'ocular/dsl/ssh'
require 'ocular/dsl/logging'

class Ocular
    module DSL

        class EventBase

            class Results
                attr_accessor :response
                attr_accessor :error
            end

            attr_accessor :proxy

            def initialize(&block)
                @callback = block
            end

            def exec(context, do_fork = self.proxy.do_fork)
                context.proxy = self.proxy
                if do_fork
                    return exec_fork(context)
                else
                    return exec_nofork(context)
                end
            end

            def exec_fork(context)
                reader, writer = IO::pipe
                child_pid = fork do
                    reader.close
                    r = Results.new

                    begin
                        r.response = __call(context, @callback)
                        #r.response = context.instance_eval(&@callback)
                    rescue Exception => error
                        r.error = error
                    end

                    response_data = Marshal.dump(r)
                    writer.puts(response_data)
                    writer.close
                end
                writer.close

                Process.wait(child_pid)
                r = Marshal.load(reader.read)
                reader.close

                if r.error
                    raise r.error
                end
                return r.response
            end

            def exec_nofork(context)
                return __call(context, @callback)
                #context.instance_eval(&@callback)
            end

            def __call(context, callback)
                # we use this trickery to workaround the LocalJumpError so that we can use return
                context.define_singleton_method(:_, &callback)
                p = context.method(:_).to_proc

                return p.call()
            end

        end
    end
end

