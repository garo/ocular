# ocular
Framework to automate responses for infrastructure events.

Ocular allows to easily create small scripts which are triggered from multiple different event sources and which can then execute scripts commanding all kinds of infrastructure, do remote command execution, execute AWS API calls, modify databases and so on.

The goal is that a new script could be written really quickly to automate a previously manual infrastructure maintenance job instead of doing the manual job yet another time. Scripts are written in Ruby with a simple Ocular DSL which allows the script to easily respond to multitude different events.

Planned event sources:
 - HTTP calls
 - RabbitMQ messages
 - SQS/SNS messages
 - Graphite item triggers
 - Zabbix alerts
 - Timers
 
