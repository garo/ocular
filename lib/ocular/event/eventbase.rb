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
                        retval = context.instance_eval(&@callback)

                        # This check is to make sure that whatever we return that it can be serialised
                        if String === retval or Array === retval
                            r.response = retval
                        end

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
                return context.instance_eval(&@callback)
            end

        end
    end
end

