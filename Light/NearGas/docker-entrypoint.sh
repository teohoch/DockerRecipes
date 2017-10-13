#!/bin/bash
set -e

echo "Installing and updating gems"

git pull

bundle install && bundle update

echo "Creating database if it doesn't exist and runing migrations"
rake db:migrate 2>/dev/null || rake db:setup

exec "$@"
