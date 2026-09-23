# Kubo — ERP + CRM autoalojable para PYMES

Kubo es un sistema ERP/CRM pensado para negocios pequeños y medianos que necesitan
digitalizar sus procesos sin pagar suscripciones SaaS. Se instala en el local del
negocio (mini-PC o VPS económico) con un solo comando, funciona como PWA instalable
y opera sin conexión a internet.

## Estado

| Campo | Valor |
| --- | --- |
| Versión | `0.1.0-mvp` |
| Fecha | 2026-09-23 |
| Alcance | MVP demostrable (ver `kubo-docs/09-demo-guion.md`) |
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
make up      # construye y levanta los 8 contenedores
make smoke   # prueba el flujo completo end-to-end
make down    # detiene el sistema
```

Luego abrir <http://localhost:3000> y entrar con `admin@kubo.local` / `Admin123!`.

## Documentación

- Arquitectura: [`kubo-docs/01-arquitectura.md`](./kubo-docs/01-arquitectura.md)
- Seguridad: [`kubo-docs/04-seguridad.md`](./kubo-docs/04-seguridad.md)
- Modelo de datos: [`kubo-docs/02-modelo-datos.md`](./kubo-docs/02-modelo-datos.md)
- Guion de demostración: [`kubo-docs/09-demo-guion.md`](./kubo-docs/09-demo-guion.md)
- Índice completo: [`kubo-docs/README.md`](./kubo-docs/README.md)
