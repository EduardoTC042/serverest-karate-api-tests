function() {
  // Hook afterScenario: elimina los usuarios registrados en `idsParaLimpiar`,
  // aunque el escenario haya fallado. Mantiene limpia la instancia compartida.
  // Uso en el Background:
  // * def idsParaLimpiar = []
  // * configure afterScenario = limpiarUsuarios
  // Evita ejecutarse dentro de features "llamados" (helpers), si el hook fuera heredado.
  var dir = '' + karate.info.featureDir;
  if (dir.indexOf('helpers') >= 0) return;
  var ids = karate.get('idsParaLimpiar') || [];
  for (var i = 0; i < ids.length; i++) {
    try {
      karate.call(karate.get('helpers').eliminarUsuario, { id: ids[i] });
    } catch (e) {
      karate.log('[limpieza] No se pudo eliminar el usuario', ids[i], e);
    }
  }
}
