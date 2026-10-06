# ServeRest – Pruebas de API de Usuarios con Karate DSL

Suite de pruebas automatizadas para el recurso **`/usuarios`** de la API [ServeRest](https://serverest.dev/), construida con **Karate DSL 1.5** sobre **Java 17 + Maven + JUnit 5**.

> Informe de estrategia y patrones: [`docs/ESTRATEGIA.md`](docs/ESTRATEGIA.md)

## Cobertura

| Endpoint | Feature | Positivos | Negativos |
|---|---|---|---|
| `POST /usuarios` | `crear-usuario.feature` | Alta de admin y no admin + verificación de persistencia | Email duplicado, body vacío, **11 validaciones de campos (data-driven)** |
| `GET /usuarios` | `listar-usuarios.feature` | Contrato del listado, filtros por `email`, `_id`, `nome`, `administrador`, filtros combinados, sin resultados | Filtro con valor inválido, parámetro no soportado |
| `GET /usuarios/{_id}` | `consultar-usuario.feature` | Consulta de usuario existente + esquema | Id inexistente, 3 formatos de id inválidos |
| `PUT /usuarios/{_id}` | `actualizar-usuario.feature` | Actualización total, actualización conservando email, *upsert* sobre id inexistente | Email de otro usuario, **11 validaciones (data-driven)** |
| `DELETE /usuarios/{_id}` | `eliminar-usuario.feature` | Eliminación + verificación | Id inexistente, doble eliminación, **usuario con carrito** |
| Flujo completo | `flujo-crud-usuario.feature` | Alta → consulta → listado → actualización → baja → verificación | — |

**Total: 50 escenarios** (contando cada fila de los *Scenario Outline*).

## Requisitos

- **Java 17+** (`java -version`)
- **Maven 3.8+** (`mvn -v`)
- Acceso a internet hacia `https://serverest.dev` (o ServeRest local, ver abajo)

## Instalación

```bash
git clone https://github.com/<tu-usuario>/serverest-karate-api-tests.git
cd serverest-karate-api-tests
mvn -q dependency:resolve     # opcional: descarga dependencias
```

## Ejecución

| Comando | Descripción |
|---|---|
| `mvn test` | Ejecuta toda la suite en paralelo (4 hilos) contra `https://serverest.dev` |
| `mvn test -Dkarate.options="--tags @smoke"` | Solo pruebas de humo |
| `mvn test -Dkarate.options="--tags @negativo"` | Solo casos negativos |
| `mvn test -Dkarate.options="--tags @crear,@eliminar"` | Varios tags (OR) |
| `mvn test -Dkarate.options="--tags @usuarios --tags ~@integracion"` | Tags combinados (AND / exclusión) |
| `mvn test -Dkarate.options="classpath:com/serverest/usuarios/crear-usuario.feature"` | Un solo feature |
| `mvn test -Dthreads=1` | Ejecución secuencial |
| `mvn test -Dkarate.env=local` | Contra ServeRest local (`http://localhost:3000`) |
| `mvn test -DbaseUrl=https://mi-servidor` | URL arbitraria |

### Ejecutar contra ServeRest local (recomendado para ejecuciones intensivas)

```bash
npx serverest@latest          # levanta la API en http://localhost:3000
mvn test -Dkarate.env=local
```

### Tags disponibles

`@usuarios` `@crear` `@listar` `@consultar` `@actualizar` `@eliminar` `@e2e` `@smoke` `@positivo` `@negativo` `@contrato` `@data-driven` `@integracion`

## Reportes

Después de la ejecución:

- **`target/karate-reports/karate-summary.html`** – reporte HTML de Karate con cada request/response.
- `target/karate-reports/*.json` – formato Cucumber JSON (integrable con Jenkins/Xray).
- `target/karate-reports/*.xml` – JUnit XML.
- `target/karate.log` – log completo.

## Estructura del proyecto

```
.
├── pom.xml
├── src/test/java
│   ├── karate-config.js                    # Entornos, baseUrl, esquemas, mensajes y utilidades globales
│   ├── logback-test.xml
│   └── com/serverest
│       ├── ServeRestTest.java              # Runner JUnit 5 (paralelo, falla el build si hay errores)
│       ├── usuarios/                       # Features de prueba (uno por operación)
│       │   ├── crear-usuario.feature
│       │   ├── listar-usuarios.feature
│       │   ├── consultar-usuario.feature
│       │   ├── actualizar-usuario.feature
│       │   ├── eliminar-usuario.feature
│       │   └── flujo-crud-usuario.feature
│       └── common/
│           ├── helpers/                    # Features reutilizables (@ignore): CRUD y limpieza de recursos
│           ├── schemas/                    # Esquemas JSON (fuzzy matching de Karate)
│           ├── data/                       # Mensajes esperados y datos inválidos (data-driven)
│           └── utils/                      # Generador de datos (DataFaker), id aleatorio, limpieza
├── docs/ESTRATEGIA.md
└── .github/workflows/api-tests.yml         # CI en GitHub Actions
```

## Datos de prueba

- Cada escenario **crea sus propios usuarios** con datos únicos (`generarUsuario()`: DataFaker + UUID), por lo que la suite es independiente del estado de la base y puede ejecutarse en paralelo.
- Al terminar cada escenario (incluso si falla) un hook `afterScenario` limpia los recursos creados en orden: cancela carritos, elimina productos y, finalmente, usuarios. Si algún paso de limpieza falla, el escenario queda marcado como fallido con el detalle del recurso afectado.

## Subir el proyecto a GitHub

```bash
git remote add origin https://github.com/<tu-usuario>/serverest-karate-api-tests.git
git branch -M main
git push -u origin main
```
