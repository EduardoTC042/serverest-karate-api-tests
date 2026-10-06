function() {
  // Hook afterScenario: limpia los recursos del escenario incluso si falla.
  // Uso en el Background:
  // * def idsParaLimpiar = []
  // * configure afterScenario = limpiarUsuarios
  // Evita ejecutarse dentro de features "llamados" (helpers), si el hook fuera heredado.
  var dir = '' + karate.info.featureDir;
  if (dir.indexOf('helpers') >= 0) return;

  var fallos = [];
  var carritos = karate.get('carritosParaLimpiar') || [];
  var productos = karate.get('productosParaLimpiar') || [];
  var usuarios = karate.get('idsParaLimpiar') || [];

  // Cancelar los carritos antes de borrar productos y usuarios.
  for (var i = 0; i < carritos.length; i++) {
    try {
      karate.call(karate.get('helpers').cancelarCarrito, carritos[i]);
    } catch (e) {
      fallos.push('carrito ' + carritos[i].id + ': ' + e);
    }
  }
  for (var j = 0; j < productos.length; j++) {
    try {
      karate.call(karate.get('helpers').eliminarProducto, productos[j]);
    } catch (e) {
      fallos.push('producto ' + productos[j].id + ': ' + e);
    }
  }
  for (var k = 0; k < usuarios.length; k++) {
    try {
      karate.call(karate.get('helpers').eliminarUsuario, { id: usuarios[k] });
    } catch (e) {
      fallos.push('usuario ' + usuarios[k] + ': ' + e);
    }
  }

  if (fallos.length > 0) {
    karate.fail('No se pudieron limpiar todos los datos de prueba: ' + fallos.join('; '));
  }
}
