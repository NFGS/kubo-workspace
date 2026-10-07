# Kubo — ERP + CRM autoalojable para PYMES
[!\[Licencia: MIT](https://img.shields.io/badge/licencia-MIT-green.svg)\](LICENSE) [!\[Release](https://img.shields.io/github/v/release/NFGS/kubo-workspace?label=release)\]([https://github.com/NFGS/kubo-workspace/releases](https://github.com/NFGS/kubo-workspace/releases))
Kubo es un sistema ERP/CRM pensado para negocios pequeños y medianos que necesitan
digitalizar sus procesos sin pagar suscripciones SaaS. Se instala en el local del
negocio (mini-PC o VPS económico) con un solo comando, funciona como PWA instalable
y opera sin conexión a internet.
## Estado
<table header-row="true">
<tr>
<td>Campo</td>
<td>Valor</td>
</tr>
<tr>
<td>Versión</td>
<td>`0.3.0` (MVP + fases 0–6: confiabilidad, calidad, núcleo comercial, diferenciadores y operación)</td>
</tr>
<tr>
<td>Fecha</td>
<td>2026-10-05</td>
</tr>
<tr>
<td>Alcance</td>
<td>Producto operable en un negocio (ver `kubo-docs/11-plan-de-cierre.md`)</td>
</tr>
<tr>
<td>Demo pública</td>
<td>\<[https://kubo.shares.zrok.io](https://kubo.shares.zrok.io)\> — túnel zrok (100 % OSS, ADR-0028); la ruta directa/VPS queda documentada en `kubo-docs/05-despliegue.md` §9</td>
</tr>
<tr>
<td>Repositorios</td>
<td>Públicos con licencia MIT y CI verde en GitHub Actions (ADR-0029)</td>
</tr>
<tr>
<td>Verificación</td>
<td>`make smoke` 192/192 · `make ci` 13/13 · `make contracts` 23/23 · `make e2e` 5/5 · `make load` 50 cajas 100 % de ventas (p95 107 ms con 10 cajas) · `make bus-drill` 4/4 · `make restore-drill` 14/14</td>
</tr>
<tr>
<td>Auditoría</td>
<td>`kubo-docs/10-auditoria.md` — 17 hallazgos corregidos; los 31 pendientes priorizados quedaron cerrados en las fases 1–6 (resta el backlog comercial y externo)</td>
</tr>
<tr>
<td>Plan de cierre</td>
<td>`kubo-docs/11-plan-de-cierre.md` — fases 0–6 completadas; quedan las mejoras continuas</td>
</tr>
<tr>
<td>Licencia</td>
<td>MIT</td>
</tr>
</table>
## Repositorios
<table header-row="true">
<tr>
<td>Repo</td>
<td>Responsabilidad</td>
<td>Stack</td>
</tr>
<tr>
<td>[`kubo-gateway`](./kubo-gateway)</td>
<td>API Gateway, autenticación, rate limiting</td>
<td>TypeScript + NestJS</td>
</tr>
<tr>
<td>[`kubo-iam`](./kubo-iam)</td>
<td>Identidad, tenants, roles, auditoría</td>
<td>Java 21 + Spring Boot 4</td>
</tr>
<tr>
<td>[`kubo-crm`](./kubo-crm)</td>
<td>Clientes, cifrado de PII, pipeline</td>
<td>Ruby + Rails 8</td>
</tr>
<tr>
<td>[`kubo-erp`](./kubo-erp)</td>
<td>Catálogo, inventario, ventas</td>
<td>Elixir + Phoenix</td>
</tr>
<tr>
<td>[`kubo-analytics`](./kubo-analytics)</td>
<td>KPIs, tablero, agregaciones</td>
<td>Python + FastAPI</td>
</tr>
<tr>
<td>[`kubo-web`](./kubo-web)</td>
<td>PWA (offline-first)</td>
<td>React 19 + Vite + Tailwind</td>
</tr>
<tr>
<td>[`kubo-infra`](./kubo-infra)</td>
<td>Compose, seed, smoke tests</td>
<td>Docker</td>
</tr>
<tr>
<td>[`kubo-docs`](./kubo-docs)</td>
<td>Arquitectura, ADRs, manuales</td>
<td>Markdown + Mermaid</td>
</tr>
</table>
## Clonar el proyecto
El código vive en **9 repositorios** (polyrepo deliberado, ADR-0002). El
workspace es la puerta de entrada:
```bash
git clone https://github.com/NFGS/kubo-workspace.git
cd kubo-workspace
make clone                                   # clona los 8 repos hijos
cp kubo-infra/.env.example kubo-infra/.env    # completar claves (ver abajo)
make up                                      # construye y levanta el sistema
```
## Arranque rápido
```bash
make up      # construye y levanta los 12 contenedores
make smoke   # prueba el flujo completo end-to-end
make ci      # gate de calidad: secretos, suites, contratos, humo y E2E
make down    # detiene el sistema
```
Luego abrir \<[http://localhost:3000](http://localhost:3000)\> y entrar con `admin@kubo.local` / `Admin123!`.
El acceso por HTTPS queda en \<[https://localhost:3443](https://localhost:3443)\> (certificado interno de Caddy).
## Documentación
- Arquitectura: [`kubo-docs/01-arquitectura.md`](./kubo-docs/01-arquitectura.md)
- Seguridad: [`kubo-docs/04-seguridad.md`](./kubo-docs/04-seguridad.md)
- Modelo de datos: [`kubo-docs/02-modelo-datos.md`](./kubo-docs/02-modelo-datos.md)
- **Auditoría técnica y catálogo de pendientes**: [`kubo-docs/10-auditoria.md`](./kubo-docs/10-auditoria.md)
- **Plan de cierre**: [`kubo-docs/11-plan-de-cierre.md`](./kubo-docs/11-plan-de-cierre.md)
- Guion de demostración: [`kubo-docs/09-demo-guion.md`](./kubo-docs/09-demo-guion.md)
- Índice completo: [`kubo-docs/README.md`](./kubo-docs/README.md)
- PDF consolidado: `Kubo-Documentacion.pdf` (generar con `make pdf`)
