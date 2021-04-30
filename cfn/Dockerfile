FROM ruby:2.7

# Enable jemalloc
RUN apt-get update && apt-get install libjemalloc2 && rm -rf /var/lib/apt/lists/*
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
ENV RUBYOPT="-W:no-deprecated -W:no-experimental"

# Developer Toolkit
RUN apt-get dist-upgrade && apt-get update && apt-get install -y build-essential graphviz

WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app
