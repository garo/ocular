FROM ubuntu:16.04

RUN apt-get update && apt-get install -y ruby ruby-dev libmysqlclient-dev build-essential && mkdir /ocular
ADD . /ocular
RUN gem build ocular.gemspec && gem install *.gem
