NAME		= inception
COMPOSE_DIR	= ./srcs
COMPOSE		= docker compose -f $(COMPOSE_DIR)/docker-compose.yml
DATA_DIR	= /home/cbahry/data

all: up

prepare:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress

build: prepare
	@echo "[+] Building Inception Docker images..."
	$(COMPOSE) build

up: prepare
	@echo "[+] Launching Inception infrastructure..."
	$(COMPOSE) up -d --build

down:
	@echo "[+] Stopping Inception containers..."
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

restart:
	$(COMPOSE) restart

status:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

clean: down
	@echo "[-] Cleaning dangling Docker objects..."
	@docker system prune -f

fclean:
	@echo "[!] Performing full teardwon..."
	@$(COMPOSE) down -v --rmi all --remove-orphans 2>/dev/null || true
	@sudo rm -rf $(DATA_DIR)/mariadb/* $(DATA_DIR)/wordpress/* 2>/dev/null || true
	@docker system prune -a --volumes -f 2>/dev/null || true
	@echo "[+] Teardown complete"

re: fclean all

.PHONY: all prepare build up down start stop restart status logs clean fclean re
