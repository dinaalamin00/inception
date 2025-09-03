SRC_DIR = srcs
DATA_DIR = /home/$(USER)/data

all: build up

up: build
	mkdir -p $(DATA_DIR)/mariadb_data $(DATA_DIR)/wordpress
# 	chmod -R 755 $(DATA_DIR)/mariadb_data $(DATA_DIR)/wordpress
	cd $(SRC_DIR) && sudo docker-compose up -d

down:
	cd $(SRC_DIR) && sudo docker-compose down

build:
	cd $(SRC_DIR) && sudo docker-compose build

clean: down
	@CONTAINERS=$$(docker ps -a -q -f name=nginx -f name=wordpress -f name=mariadb); \
	if [ -n "$$CONTAINERS" ]; then sudo docker rm -f $$CONTAINERS; fi
	docker rmi -f srcs_mariadb srcs_wordpress srcs_nginx 2>/dev/null || true

fclean: clean
	@CONTAINERS=$$(docker ps -a -q -f name=nginx -f name=wordpress -f name=mariadb); \
	if [ -n "$$CONTAINERS" ]; then sudo docker rm -f $$CONTAINERS; fi
	sudo docker volume rm -f mariadb_data wordpress 2>/dev/null || true
#	sudo rm -rf $(DATA_DIR)/mariadb_data $(DATA_DIR)/wordpress
	sudo rm -rf $(DATA_DIR)
	sudo docker system prune -af --volumes

re: fclean all

.PHONY: all up down build clean fclean re