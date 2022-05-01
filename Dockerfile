FROM ruby:latest

# Necessary just to install dos2unix (For Windows)
RUN apt-get update
RUN apt-get install dos2unix

RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# requires dos2unix
RUN dos2unix main.rb

CMD ["./main.rb"]
