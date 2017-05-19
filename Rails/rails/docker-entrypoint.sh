#!/bin/bash
set -e
sleep 5
rake db:create db:migrate db:seed

exec "$@"
