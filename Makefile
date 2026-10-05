SHELL := /bin/bash
COMPOSE := docker compose -f kubo-infra/docker-compose.yml

.DEFAULT_GOAL := help

.PHONY: help clone up down build ps logs seed smoke demo restart clean foreign-stop foreign-start pdf push-github reset-demo backup backup-operator backup-operator-loop restore-drill bus-drill contracts pact ci load load-big load-big-clean e2e observability certs rotate-ca obsidian sync sync-status

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

certs: ## Genera la CA interna y los certificados de la malla (P-28)
	./kubo-infra/scripts/gen-internal-certs.sh

rotate-ca: ## Regenera la CA y los certificados y recrea la malla (P-28)
	rm -rf kubo-infra/certs
	./kubo-infra/scripts/gen-internal-certs.sh
	$(COMPOSE) up -d --force-recreate kubo-iam kubo-crm kubo-erp kubo-analytics kubo-gateway
	@echo "Malla rotada: los servicios ya confian en la CA nueva"

clone: ## Clona los 8 repos hijos del workspace (polyrepo, ADR-0002)
	./scripts/clonar-todos.sh

up: certs ## Construye y levanta todo el sistema (genera la malla si falta)
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

backup-operator: ## Un ciclo del operador de respaldos (con verificacion)
	$(COMPOSE) --profile backup run --rm kubo-backup --once
	@echo "Respaldos en kubo-infra/backups: revise el MANIFEST"

backup-operator-loop: ## Deja el operador corriendo (ciclo diario, retencion y verificacion)
	$(COMPOSE) --profile backup up -d kubo-backup

restore-drill: ## Restaura un respaldo en bases de prueba y lo verifica
	./kubo-infra/scripts/restore-drill.sh

contracts: ## Valida las respuestas reales contra el contrato OpenAPI
	node kubo-gateway/scripts/contracts.mjs

pact: ## Contratos del consumidor (PWA) y su verificacion contra la API viva
	cd kubo-web && npx vitest run --config vitest.pact.config.ts
	node kubo-gateway/scripts/pact-verify.mjs

e2e: ## E2E de la PWA con auditoria de accesibilidad (Playwright + axe)
	KUBO_AUTH_RATE_LIMIT_PER_MINUTE=1000000 $(COMPOSE) up -d kubo-gateway >/dev/null 2>&1
	@sleep 5
	@cd kubo-web && npx playwright test; \
	 status=$$?; cd "$(CURDIR)" && $(COMPOSE) up -d kubo-gateway >/dev/null 2>&1; exit $$status

observability: ## Levanta el stack de trazas (Tempo + Grafana) junto al sistema
	docker compose -f kubo-infra/docker-compose.yml -f kubo-infra/docker-compose.observability.yml --profile observability up -d
	@echo "Grafana en http://localhost:3001 (admin / kubo_admin)"

ci: ## Ejecuta las mismas verificaciones que el CI (lint, pruebas, contratos, secretos)
	./kubo-infra/scripts/ci-local.sh

load: ## Prueba de carga del POS con 50 cajas (k6); corre en la red interna del compose
	KUBO_USER_RATE_LIMIT_PER_MINUTE=1000000 $(COMPOSE) up -d kubo-gateway >/dev/null
	@for i in $$(seq 1 30); do \
	  [ "$$(docker inspect kubo-gateway --format '{{.State.Health.Status}}' 2>/dev/null)" = "healthy" ] && break; \
	  sleep 2; \
	done
	@docker run --rm -i -e KUBO_API=http://kubo-gateway:8080/api/v1 \
	  --network kubo_kubo-net \
	  -v "$(PWD)/kubo-infra/load:/load" grafana/k6 run /load/pos.js; \
	 status=$$?; $(COMPOSE) up -d kubo-gateway >/dev/null; exit $$status

load-big: ## Carga con catalogo voluminoso: siembra 50.000 productos y mide la busqueda
	./kubo-infra/load/seed-big-catalog.sh
	KUBO_USER_RATE_LIMIT_PER_MINUTE=1000000 $(COMPOSE) up -d kubo-gateway >/dev/null
	@for i in $$(seq 1 30); do \
	  [ "$$(docker inspect kubo-gateway --format '{{.State.Health.Status}}' 2>/dev/null)" = "healthy" ] && break; \
	  sleep 2; \
	done
	@docker run --rm -i -e KUBO_API=http://kubo-gateway:8080/api/v1 \
	  --network kubo_kubo-net \
	  -v "$(PWD)/kubo-infra/load:/load" grafana/k6 run /load/catalog.js; \
	 status=$$?; $(COMPOSE) up -d kubo-gateway >/dev/null; exit $$status

load-big-clean: ## Elimina el catalogo voluminoso de la demo
	./kubo-infra/load/seed-big-catalog.sh --clean

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

obsidian: ## Espeja la documentacion en el vault de Obsidian
	./kubo-infra/scripts/obsidian-sync.sh

sync: ## Sincroniza los 4 entornos (local, GitHub, Notion, Obsidian)
	./kubo-infra/scripts/kubo-sync.sh run

sync-status: ## Muestra el estado de sincronizacion de los 4 entornos
	./kubo-infra/scripts/kubo-sync.sh status

push-github: ## Publica los 9 repositorios en GitHub (requiere gh autenticado)
	./kubo-infra/scripts/github-push.sh
