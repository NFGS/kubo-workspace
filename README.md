# Kubo — ERP + CRM autoalojable para PYMES

Kubo es un sistema ERP/CRM pensado para negocios pequeños y medianos que necesitan
digitalizar sus procesos sin pagar suscripciones SaaS. Se instala en el local del
negocio (mini-PC o VPS económico) con un solo comando, funciona como PWA instalable
y opera sin conexión a internet.

## Estado

| Campo | Valor |
| --- | --- |
| Versión | `0.3.0` (MVP + fases 0–6: confiabilidad, calidad, núcleo comercial, diferenciadores y operación) |
| Fecha | 2026-10-04 |
| Alcance | Producto operable en un negocio (ver `kubo-docs/11-plan-de-cierre.md`) |
| Verificación | `make smoke` 192/192 · `make ci` 13/13 · `make contracts` 23/23 · `make e2e` 5/5 · `make load` 50 cajas 100 % de ventas (p95 107 ms con 10 cajas) · `make bus-drill` 4/4 · `make restore-drill` 14/14 |
| Auditoría | `kubo-docs/10-auditoria.md` — 17 hallazgos corregidos; los 31 pendientes priorizados quedaron cerrados en las fases 1–6 (resta el backlog comercial y externo) |
| Plan de cierre | `kubo-docs/11-plan-de-cierre.md` — fases 0–6 completadas; quedan las mejoras continuas |
| Licencia | MIT |

## Repositorios

| Repo | Responsabilidad | Stack |
| --- | --- | --- |
| [`kubo-gateway`](./kubo-gateway) | API Gateway, autenticación, rate limiting | TypeScript + NestJS |
| [`kubo-iam`](./kubo-iam) | Identidad, tenants, roles, auditoría | Java 21 + Spring Boot 4 |
| [`kubo-crm`](./kubo-crm) | Clientes, cifrado de PII, pipeline | Ruby + Rails 8 |
| [`kubo-erp`](./kubo-erp) | Catálogo, inventario, ventas | Elixir + Phoenix |
| [`kubo-analytics`](./kubo-analytics) | KPIs, tablero, agregaciones | Python + FastAPI |
| [`kubo-web`](./kubo-web) | PWA (offline-first) | React 19 + Vite + Tailwind |
| [`kubo-infra`](./kubo-infra) | Compose, seed, smoke tests | Docker |
| [`kubo-docs`](./kubo-docs) | Arquitectura, ADRs, manuales | Markdown + Mermaid |

## Arranque rápido

```bash
make up      # construye y levanta los 12 contenedores
make smoke   # prueba el flujo completo end-to-end
make ci      # gate de calidad: secretos, suites, contratos, humo y E2E
make down    # detiene el sistema
```

Luego abrir <http://localhost:3000> y entrar con `admin@kubo.local` / `Admin123!`.
El acceso por HTTPS queda en <https://localhost:3443> (certificado interno de Caddy).

## Documentación

- Arquitectura: [`kubo-docs/01-arquitectura.md`](./kubo-docs/01-arquitectura.md)
- Seguridad: [`kubo-docs/04-seguridad.md`](./kubo-docs/04-seguridad.md)
- Modelo de datos: [`kubo-docs/02-modelo-datos.md`](./kubo-docs/02-modelo-datos.md)
- **Auditoría técnica y catálogo de pendientes**: [`kubo-docs/10-auditoria.md`](./kubo-docs/10-auditoria.md)
- **Plan de cierre**: [`kubo-docs/11-plan-de-cierre.md`](./kubo-docs/11-plan-de-cierre.md)
- Guion de demostración: [`kubo-docs/09-demo-guion.md`](./kubo-docs/09-demo-guion.md)
- Índice completo: [`kubo-docs/README.md`](./kubo-docs/README.md)
- PDF consolidado: `Kubo-Documentacion.pdf` (generar con `make pdf`)
