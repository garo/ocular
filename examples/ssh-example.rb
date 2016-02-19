require 'pp'

onEvent nil do
    asdf("localhost")
end

def asdf(host)
    r = ssh_to(host)
    pp r.execute("ls")
end

