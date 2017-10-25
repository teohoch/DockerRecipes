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

RUN git clone https://github.com/teohoch/neargass.git

ENV APP_HOME /neargass
WORKDIR $APP_HOME

RUN cd /neargass

RUN bundle install

COPY docker-entrypoint.sh /usr/local/bin/
COPY database.yml /database.yml
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["rails", "server", "-p", "3000", "-b", "0.0.0.0"]
