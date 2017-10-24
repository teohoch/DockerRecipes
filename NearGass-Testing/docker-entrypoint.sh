#!/bin/bash
set -e

cp -fr /database.yml /neargass/config/database.yml

bundle install && bundle update

rake db:migrate 2>/dev/null || rake db:setup

exec "$@"
