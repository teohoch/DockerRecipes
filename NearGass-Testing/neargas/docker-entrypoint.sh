#!/bin/bash
set -e

cp -fr /database.yml /neargass/config/database.yml

bundle install  --job 3 --quiet && bundle update  --job 3 --quiet

rake db:migrate 2>/dev/null || rake db:setup

exec "$@"
