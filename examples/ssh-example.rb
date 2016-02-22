require 'pp'

onEvent nil do
    ssh_example(ARGV[0])
end

def ssh_example(host)
    debug("Connecting to #{host}")
    r = ssh_to(host)
    pp r.execute("ls /")
end

