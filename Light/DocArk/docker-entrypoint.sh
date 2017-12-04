#!/bin/bash
set -e

echo "Installing and updating gems"

git pull

cp -fr /database.yml /DocArk/config/database.yml
cp -fr /secrets.yml.key /DocArk/config/secrets.yml.key


bundle install

echo "Creating database if it doesn't exist and runing migrations"
rake db:migrate 2>/dev/null
rails assets:clean
rails assets:precompile

exec "$@"
