
onEvent nil do
    debug("Converging array #{ARGV[0]}")
    for i in autoscaling.groups.get(ARGV[0]).instances
        server = aws.servers.get(i.id)
        hostname = server.private_ip_address
        debug("Connecting to #{hostname}")
        c = ssh_to(hostname)

        uptime = c.execute("cat /proc/uptime")[0].to_i
        if uptime < 2700
            debug("Uptime of #{hostname} is less than 2700: #{uptime}")
        else
            running_containers = c.sudo("docker ps | tail -n +2").length
            if running_containers == 0
                info("No running containers in host #{hostname}, running converge")
                log(c.execute("sudo converge.sh | sudo tee -a /var/log/init.err"))
            else
                info("Host #{hostname} ok with #{running_containers} running containers")
            end
        end        
    end
end

