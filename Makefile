LOGIN       = cbahry
DATA_DIR    = /home/$(LOGIN)/data
COMPOSE     = docker compose -f srcs/docker-compose.yml

all: up

up: dirs
	$(COMPOSE) up -d --build

dirs:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

clean: down

fclean:
	$(COMPOSE) down -v --rmi all
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all up dirs down stop start ps logs clean fclean re
