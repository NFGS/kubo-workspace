# Seguridad

## Reportar una vulnerabilidad

Si encuentras una vulnerabilidad en Kubo, **no abras un issue público**:
escribe a **nelson.fabian.gallego.s@gmail.com** con la descripción, los pasos
de reproducción y el impacto estimado. Respondemos en un plazo de 5 días
hábiles.

## Alcance

- Este repositorio (workspace) y los 8 repositorios hijos del proyecto.
- La demo pública (`https://kubo.shares.zrok.io`) es un entorno de
  **demostración** con datos de ejemplo: no contiene datos reales de negocios.

## Prácticas de seguridad del proyecto

- **Cero secretos en el repositorio**: las claves viven en `kubo-infra/.env`
  (ignorado) o en los secretos generados por el despliegue (ADR-0028).
- Escaneo de secretos en el gate (`make ci`).
- Aislamiento por negocio con **RLS** activo en las tres bases (ADR-0010).
- **Cifrado de campos** personales con AES-256-GCM e índice ciego (ADR-0006).
- **mTLS** en la malla interna entre gateway y servicios (ADR-0020).
- Auditoría encadenada, límites de tasa y segundo factor TOTP (ADR-0015).
- Detalle completo en `kubo-docs/04-seguridad.md`.
