FROM ruby:2.5.0

ENV LANG C.UTF-8
ENV APP_HOME /myapp

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends --allow-unauthenticated apt-utils \
                       build-essential \
                       libpq-dev \
                       nodejs \
                       mysql-client \
                       locales && \
    gem install bundler && \
    mkdir -p $APP_HOME && \
    mkdir -p /shared/tmp/sockets && \
    mkdir -p /var/run/puma/pids

WORKDIR $APP_HOME

ADD ./Gemfile $APP_HOME/Gemfile
ADD ./Gemfile.lock $APP_HOME/Gemfile.lock
RUN bundle install
ADD . $APP_HOME
