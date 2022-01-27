# === Makefile Helper ===
# Styles
YELLOW=$(shell echo "\033[00;33m")
RED=$(shell echo "\033[00;31m")
RESTORE=$(shell echo "\033[0m")

include .env

DRUPAL_ROOT ?= /var/www/html
BRANCH_NAME=develop

.DEFAULT_GOAL := list

.PHONY: list
list:
	@echo "******************************"
	@echo "${YELLOW}Available targets${RESTORE}:"
	@grep -E '^[a-zA-Z-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf " ${YELLOW}%-15s${RESTORE} > %s\n", $$1, $$2}'
	@echo "${RED}==============================${RESTORE}"

.PHONY: create
create: ## Create and start up containers.
	@echo "Starting up containers for $(COMPOSE_PROJECT_NAME)..."
	docker-compose pull
	docker-compose up --build -d --remove-orphans
	docker-compose exec php composer install

## start	:	Start containers without updating.
.PHONY: start
start: ## Start containers without updating
	@echo "Starting containers for $(COMPOSE_PROJECT_NAME) from where you left off..."
	@docker-compose start

.PHONY: stop
stop: ## Stop containers.
	@echo "Stopping containers for $(COMPOSE_PROJECT_NAME)..."
	@docker-compose stop

.PHONY: restart
restart: ## Stop containers.
	@echo "Stopping containers for $(COMPOSE_PROJECT_NAME)..."
	@docker-compose restart

## ex. make update BRANCH_NAME=develop
.PHONY: update
update: ## Update local env from branch develop.
	@echo "Start updating from branch develop..."
	@docker-compose exec php git checkout ${BRANCH_NAME}
	@docker-compose exec php git pull origin ${BRANCH_NAME}
	@docker-compose exec php composer install

## prune	:	Remove containers and their volumes.
##		You can optionally pass an argument with the service name to prune single container
##		prune mariadb	: Prune `mariadb` container and remove its volumes.
##		prune mariadb engine	: Prune `mariadb` and `engine` containers and remove their volumes.
.PHONY: prune
prune: ## Remove containers and their volumes.
	@echo "Removing containers for $(COMPOSE_PROJECT_NAME)..."
	@docker-compose down -v $(filter-out $@,$(MAKECMDGOALS))

## ps	:	List running containers.
.PHONY: ps
ps: ## List running containers.
	@docker ps #--filter name='$(COMPOSE_PROJECT_NAME)*'

.PHONY: shell
shell: ## Access `php` container via shell.
	@docker-compose exec php bash

.PHONY: mysql
mysql: ## Access `mariadb` container via shell.
	@docker-compose exec mariadb mysql -u root -p${MYSQL_ROOT_PASSWORD}

## logs	:	View containers logs.
##		You can optinally pass an argument with the service name to limit logs
##		logs php	: View `php` container logs.
##		logs nginx php	: View `nginx` and `php` containers logs.
.PHONY: logs
logs: ## View containers logs.
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))
