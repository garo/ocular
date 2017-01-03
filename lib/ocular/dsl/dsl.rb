
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
require 'ocular/dsl/psql.rb'
require 'ocular/dsl/mongo.rb'
require 'ocular/dsl/rabbitmq.rb'
require 'ocular/dsl/graphite.rb'
require 'ocular/dsl/cache.rb'
require 'ocular/dsl/file.rb'

