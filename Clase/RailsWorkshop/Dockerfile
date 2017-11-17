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

RUN git clone https://github.com/mwlang/gentelella-rails-demo.git

ENV APP_HOME /gentelella-rails-demo/examples/rails.5.0.x/

WORKDIR $APP_HOME

RUN bundle install

RUN mkdir public/images-test
VOLUME /gentelella-rails-demo/examples/rails.5.0.x/public/images-test/


COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3000


CMD ["rails", "server", "-p", "3000", "-b", "0.0.0.0"]
