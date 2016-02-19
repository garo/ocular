require 'pp'

onEvent nil do
    asdf(ARGV[0])
end

def asdf(host)
    r = ssh_to(host)
    pp r.execute("ls")
end

