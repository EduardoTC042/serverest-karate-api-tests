# Informe: Estrategia de automatización y patrones utilizados

## 1. Alcance

Se automatiza el recurso **Usuarios** de ServeRest en sus 5 operaciones (`GET` listado, `GET` por id, `POST`, `PUT`, `DELETE`). Antes de escribir los escenarios se exploró la API real para documentar su contrato exacto (códigos, mensajes y comportamientos no obvios); los mensajes de la API están en portugués y se validan textualmente.

Comportamientos relevantes descubiertos y cubiertos por pruebas:

| Comportamiento | Cómo se valida |
|---|---|
| "No encontrado" responde **400** (no 404) | `consultar-usuario.feature`, `eliminar-usuario.feature` |
| `DELETE` de un id inexistente responde **200** con *"Nenhum registro excluído"* | Escenario de id inexistente y de doble eliminación |
| `PUT` sobre un id inexistente **crea** un usuario (upsert) con un id **generado por el servidor**, no el de la URL | `actualizar-usuario.feature` |
| Ids deben tener exactamente 16 caracteres alfanuméricos | Outline de formatos inválidos |
| `administrador` es un **string** `"true"`/`"false"`; un booleano `true` es rechazado | Data-driven de validaciones |
| Campos/parámetros desconocidos son rechazados (`"x não é permitido"`) | Validaciones de body y de query params |
| No se puede eliminar un usuario con carrito | Escenario de integración usuarios → login → productos → carritos |

**Hallazgo (posible defecto, no automatizado como fallo):** la unicidad del email es *case-sensitive*: `qa@x.com` y `QA@X.COM` se registran como usuarios distintos. Se reporta para análisis en lugar de convertirlo en una prueba que falle permanentemente.

## 2. Diseño de casos

- **Positivos y negativos por endpoint**, más un **flujo E2E** que recorre el ciclo de vida completo.
- **Particiones de equivalencia / valores límite** sobre los campos: ausente, vacío, formato inválido, tipo incorrecto, valor fuera de dominio, campo extra; y sobre el id: más corto, más largo, caracteres especiales.
- **Data-driven**: las 11 validaciones de campos viven en `common/data/usuarios-invalidos.json` y se reutilizan tanto para `POST` como para `PUT` mediante *Scenario Outline* con `Examples` dinámicos. Agregar un caso = agregar una fila JSON.
- **Verificación de efectos**, no solo del status: tras crear/actualizar/eliminar se consulta el recurso para comprobar que el cambio persistió (o que no ocurrió, en los negativos).

## 3. Validación de respuestas y esquemas

- **Esquemas JSON** en `common/schemas/` con *fuzzy matching* de Karate: tipos (`#string`, `#number`), expresiones regulares (`_id` de 16 alfanuméricos, formato de email, `administrador` ∈ {true,false}), validaciones propias (`#number? _ >= 0`) y arrays tipados (`#[] schemas.usuario`).
- **Match exacto** (`==`) del body completo siempre que es posible, para detectar campos inesperados; `contains` solo en listados compartidos con otros usuarios de la instancia pública.
- Coherencia interna del contrato: `quantidade == usuarios.length`; `Content-Type` JSON.
- **Mensajes centralizados** en `common/data/mensajes.json` (fuente única de verdad).

## 4. Manejo de datos de prueba

| Principio | Implementación |
|---|---|
| Independencia | Cada escenario crea sus propios datos; ninguno depende de usuarios preexistentes ni del orden de ejecución. |
| Unicidad | `generarUsuario()` combina **DataFaker** (nombres y passwords realistas, locale `es`) con un **UUID** en el email → sin colisiones en paralelo ni con otros usuarios de la instancia pública. |
| Sobrescritura declarativa | `generarUsuario({ administrador: 'false' })` cambia solo lo necesario para el caso. |
| Limpieza garantizada | Los ids creados se registran en `idsParaLimpiar` y el hook `afterScenario` (`limpiar-usuarios.js`) los elimina **aunque el escenario falle**. En los negativos, si la API aceptara un payload por error, el usuario creado también se registra para limpieza. |
| Configuración por entorno | `karate-config.js` resuelve `baseUrl` por `karate.env` (`dev` pública / `local`) o `-DbaseUrl`. |

## 5. Patrones utilizados

- **Arrange–Act–Assert** visible en cada escenario (comentarios marcan las fases en los más largos).
- **Reusable features / Helpers (`@ignore`)**: `crear-usuario`, `eliminar-usuario`, `login` encapsulan precondiciones y se invocan con `call read(helpers.x)`, devolviendo datos (id, payload, token) al escenario llamador. Equivalen a un *Service Object* sobre la API.
- **Test Data Builder**: `generarUsuario(overrides)` construye un payload válido por defecto que cada escenario ajusta.
- **Configuración centralizada**: `karate-config.js` expone `baseUrl`, esquemas, mensajes, utilidades y rutas a helpers a todos los features.
- **Data-Driven Testing** con `Scenario Outline` (tablas inline y Examples dinámicos desde JSON).
- **Hooks de teardown** (`afterScenario`) para limpieza.
- **Organización por operación**: un feature por endpoint/verbo y carpetas separadas para pruebas (`usuarios/`) y soporte (`common/`).
- **Tags** por operación, tipo de caso y criticidad para ejecución selectiva.

## 6. Ejecución y CI

- Runner JUnit 5 con `Runner.parallel()` (4 hilos por defecto) que **falla el build** si hay errores, y genera reportes HTML, Cucumber JSON y JUnit XML.
- GitHub Actions ejecuta la suite en cada push/PR y publica `target/karate-reports` como artefacto; permite lanzar manualmente por tags.

## 7. Riesgos y mejoras

- La instancia pública es compartida y puede reiniciarse o limitar tráfico; para ejecuciones intensivas se recomienda `npx serverest` local (`-Dkarate.env=local`).
- Extender con pruebas de rendimiento reutilizando los mismos features vía **Karate Gatling**.
- Ampliar a los recursos `login`, `produtos` y `carrinhos` reutilizando los helpers existentes.
