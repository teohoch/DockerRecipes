#!/bin/bash
set -e

echo "Getting latest project Version"

git fetch --all
git reset --hard origin/master

echo "Installing and updating gems"

# bundle install && bundle update

echo "Creating database if it doesn't exist and runing migrations"
rake db:migrate 2>/dev/null || rake db:setup

exec "$@"
