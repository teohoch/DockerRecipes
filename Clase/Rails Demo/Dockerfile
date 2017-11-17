FROM ruby:latest

RUN apt-get update -qq && apt-get install -y build-essential

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
RUN apt-get install -y nodejs

# To install rails

RUN gem install rails -v 5.0.1
RUN rails new blog

ENV APP_HOME /blog
WORKDIR $APP_HOME

EXPOSE 3000


CMD ["rails", "server", "-p", "3000", "-b", "0.0.0.0"]
