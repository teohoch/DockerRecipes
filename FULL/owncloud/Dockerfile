# Docker image of ownCloud Server (Community) on PHP 7.
# Copyright (C) 2017 Rodrigo Martínez <dev@brunneis.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FROM ubuntu:16.04
MAINTAINER "Rodrigo Martínez" <dev@brunneis.com>

ARG OWNCLOUD_VERSION=10.0.2

################################################
# OWNCLOUD X
################################################

RUN \
apt-get update && apt-get upgrade -y \
&& apt-get install -y \
	curl \
	bzip2 \
	apache2 \
	mariadb-server \
	libapache2-mod-php7.0 \
	php-gd \
	php-zip \
	php-mysql \
	php-pgsql \
	php-imap \
	php-ldap \
	php-gmp \
	php-json \
	php-curl \
	php-intl \
	php-mcrypt \
	php-imagick \
	php-xml \
	php-mbstring \
	php-smbclient \
	php-apcu \
	php-memcached \
	php-redis \
	php-sqlite3 \
	php-bz2 \
&& rm -rf /var/lib/apt/lists/*

ENV HTML_DIR /var/www/html

VOLUME $HTML_DIR
VOLUME $HTML_DIR/data
VOLUME $HTML_DIR/config
VOLUME $HTML_DIR/apps

RUN curl -fsSL -o owncloud.tar.bz2 \
		"https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2" \
	&& curl -fsSL -o owncloud.tar.bz2.asc \
		"https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
# gpg key from https://owncloud.org/owncloud.asc
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys E3036906AD9F30807351FAC32D5D5E97F6978A26 \
	&& gpg --batch --verify owncloud.tar.bz2.asc owncloud.tar.bz2 \
	&& rm -r "$GNUPGHOME" owncloud.tar.bz2.asc \
	&& tar -xjf owncloud.tar.bz2 -C /usr/src/ \
	&& rm owncloud.tar.bz2

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid

COPY apache2.conf /etc/apache2/apache2.conf
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
