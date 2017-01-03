FROM ubuntu:16.04

RUN apt-get update && apt-get install -y ruby libpq-dev ruby-dev libmysqlclient-dev build-essential && mkdir /ocular
ADD . /ocular
RUN cd /ocular && gem build ocular.gemspec && gem install *.gem
