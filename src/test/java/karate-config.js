function fn() {
  // Entorno: mvn test -Dkarate.env=local  (por defecto: dev = instancia pública)
  var env = karate.env || 'dev';
  var urls = {
    dev: 'https://serverest.dev',
    local: 'http://localhost:3000'   // npx serverest@latest
  };
  // -DbaseUrl=... tiene prioridad sobre el entorno
  var baseUrl = karate.properties['baseUrl'] || urls[env];
  if (!baseUrl) {
    karate.fail('Entorno no soportado: ' + env + '. Usa uno de: ' + Object.keys(urls));
  }
  karate.log('karate.env =', env, '| baseUrl =', baseUrl);

  var base = 'classpath:com/serverest/common/';
  var config = {
    env: env,
    baseUrl: baseUrl,
    // Mensajes esperados de la API (fuente única de verdad)
    msg: read(base + 'data/mensajes.json'),
    // Esquemas JSON (fuzzy matching de Karate)
    schemas: {
      usuario: read(base + 'schemas/usuario.json'),
      listaUsuarios: read(base + 'schemas/lista-usuarios.json'),
      mensaje: read(base + 'schemas/mensaje.json'),
      mensajeConId: read(base + 'schemas/mensaje-con-id.json')
    },
    // Utilidades de datos de prueba
    generarUsuario: read(base + 'utils/generar-usuario.js'),
    limpiarUsuarios: read(base + 'utils/limpiar-usuarios.js'),
    idAleatorio: read(base + 'utils/id-aleatorio.js'),
    // Rutas a helpers reutilizables
    helpers: {
      crearUsuario: base + 'helpers/crear-usuario.feature',
      eliminarUsuario: base + 'helpers/eliminar-usuario.feature',
      cancelarCarrito: base + 'helpers/cancelar-carrito.feature',
      eliminarProducto: base + 'helpers/eliminar-producto.feature',
      login: base + 'helpers/login.feature'
    }
  };

  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 20000);
  karate.configure('headers', { Accept: 'application/json' });
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);
  return config;
}
