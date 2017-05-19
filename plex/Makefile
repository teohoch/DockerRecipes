setup:
	#Create Folders for Plex and give them permissions
	@mkdir -p ~/media
	@mkdir -p ~/plex/config
	@mkdir -p ~/plex/transcode

	@chmod -R 777 ~/media ~/plex/config ~/plex/transcode
	
	#Build the images
	@docker-compose build

start:
	@docker-compose up -d

stop:
	@docker-compose stop

status:
	@docker-compose ps

restart: stop start

clean: stop
	@docker-compose rm --force
	@find . -name \*.pyc -delete

build:
	@docker-compose build 

tail:
	@docker-compose logs -f

.PHONY: start stop status restart clean build tail
