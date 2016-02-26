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

            attr_accessor :proxy, :do_fork

            def initialize(&block)
                @do_fork = true
                @callback = block
            end

            def exec(context)
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
                    puts "inside fork"
                    reader.close
                    r = Results.new

                    begin
                        puts "Calling block from inside fork"
                        retval = context.instance_eval(&@callback)

                        # This check is to make sure that whatever we return that it can be serialised
                        if String === retval or Array === retval
                            r.response = retval
                        end

                        puts "Block done"
                    rescue Exception => error
                        puts "Error on calling block"
                        r.error = error
                    end

                    response_data = Marshal.dump(r)
                    writer.puts(response_data)
                    writer.close
                end
                writer.close

                puts "Waiting child to exit"
                Process.wait(child_pid)
                puts "child is dead"
                r = Marshal.load(reader.read)
                puts "response: #{r}"
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

