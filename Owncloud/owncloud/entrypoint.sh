#!/bin/bash
set -e

cd $HTML_DIR
if [ ! -e 'version.php' ]; then
	tar cf - --one-file-system -C /usr/src/owncloud . | tar xf -
	chown -R www-data $HTML_DIR
fi

exec "$@"
