
$dsl_help = {}

def add_help(name, help)
    $dsl_help[name] = help
end

$dsl_event_help = {}

def add_event_help(name, help)
    $dsl_event_help[name] = help
end


require 'ocular/dsl/etcd.rb'
require 'ocular/dsl/fog.rb'
require 'ocular/dsl/logging.rb'
require 'ocular/dsl/ssh.rb'
require 'ocular/dsl/orbit.rb'
require 'ocular/dsl/mysql.rb'

