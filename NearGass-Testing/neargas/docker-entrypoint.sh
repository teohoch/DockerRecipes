#!/bin/bash
set -e

cp -fr /database.yml /neargass/config/database.yml

bundle install  --jobs 3 --quiet && bundle update  --jobs 3 --quiet

rake db:migrate 2>/dev/null || rake db:setup

exec "$@"
