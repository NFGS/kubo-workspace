SHELL := /bin/bash
COMPOSE := docker compose -f kubo-infra/docker-compose.yml

.DEFAULT_GOAL := help

.PHONY: help up down build ps logs seed smoke demo restart clean foreign-stop foreign-start pdf push reset-demo backup restore-drill bus-drill contracts ci load e2e observability

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

up: ## Construye y levanta todo el sistema
	$(COMPOSE) up -d --build
	@echo "Kubo disponible en http://localhost:3000"

down: ## Detiene el sistema (conserva datos)
	$(COMPOSE) down

build: ## Solo construye las imagenes
	$(COMPOSE) build

ps: ## Estado de los contenedores
	$(COMPOSE) ps

logs: ## Logs en vivo
	$(COMPOSE) logs -f --tail=80

seed: ## Carga datos de demostracion
	./kubo-infra/scripts/seed.sh

reset-demo: ## Limpia los datos de prueba y recarga la semilla (borra datos)
	./kubo-infra/scripts/reset-demo.sh

smoke: ## Prueba el flujo completo end-to-end
	./kubo-infra/scripts/smoke.sh

bus-drill: ## Simulacro: caida del bus sin perdida de eventos
	./kubo-infra/scripts/bus-drill.sh

backup: ## Respalda PostgreSQL, MongoDB y la configuracion
	./kubo-infra/scripts/backup.sh

restore-drill: ## Restaura un respaldo en bases de prueba y lo verifica
	./kubo-infra/scripts/restore-drill.sh

contracts: ## Valida las respuestas reales contra el contrato OpenAPI
	node kubo-gateway/scripts/contracts.mjs

e2e: ## E2E de la PWA con auditoria de accesibilidad (Playwright + axe)
	cd kubo-web && npx playwright test

observability: ## Levanta el stack de trazas (Tempo + Grafana) junto al sistema
	docker compose -f kubo-infra/docker-compose.yml -f kubo-infra/docker-compose.observability.yml --profile observability up -d
	@echo "Grafana en http://localhost:3001 (admin / kubo_admin)"

ci: ## Ejecuta las mismas verificaciones que el CI (lint, pruebas, contratos, secretos)
	./kubo-infra/scripts/ci-local.sh

load: ## Prueba de carga del POS con 50 cajas (k6); eleva el limite por usuario durante la prueba
	KUBO_USER_RATE_LIMIT_PER_MINUTE=1000000 $(COMPOSE) up -d kubo-gateway >/dev/null
	@sleep 5
	@docker run --rm -i -e KUBO_API=http://host.docker.internal:9080/api/v1 \
	  --add-host=host.docker.internal:host-gateway \
	  -v "$(PWD)/kubo-infra/load:/load" grafana/k6 run /load/pos.js; \
	 status=$$?; $(COMPOSE) up -d kubo-gateway >/dev/null; exit $$status

demo: up ## Levanta y abre el navegador
	@sleep 2 && xdg-open http://localhost:3000 >/dev/null 2>&1 || true

restart: ## Reinicia los servicios de aplicacion
	$(COMPOSE) restart kubo-iam kubo-gateway kubo-crm kubo-erp kubo-analytics kubo-web

clean: ## Detiene y borra volumenes (pierde datos)
	$(COMPOSE) down -v

foreign-stop: ## Detiene contenedores ajenos al proyecto para liberar RAM
	./kubo-infra/scripts/foreign-stop.sh

foreign-start: ## Reactiva los contenedores ajenos
	./kubo-infra/scripts/foreign-start.sh

pdf: ## Genera el PDF consolidado de documentacion
	./kubo-docs/scripts/build-pdf.sh

push: ## Publica los 9 repositorios en GitLab (requiere GITLAB_TOKEN)
	./kubo-infra/scripts/gitlab-push.sh
