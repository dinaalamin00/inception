# Makefile for Inception project

SRC_DIR = srcs
DATA_DIR = /home/$(USER)/data

all: build up

up: build
	mkdir -p $(DATA_DIR)/mariadb_data
	mkdir -p $(DATA_DIR)/wordpress
	cd $(SRC_DIR) && docker-compose up -d

down:
	cd $(SRC_DIR) && docker-compose down

build:
	cd $(SRC_DIR) && docker-compose build

clean: down
	-docker rmi -f $$(docker images -q)

fclean: down
	-docker volume rm -f mariadb_data wordpress 2>/dev/null || true
	-rm -rf $(DATA_DIR)
	-docker system prune -af --volumes

re: fclean all

.PHONY: all up down build clean fclean re
