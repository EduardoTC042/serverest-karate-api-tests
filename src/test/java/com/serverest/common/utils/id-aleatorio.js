function() {
  // Devuelve un id con formato válido para ServeRest (16 caracteres alfanuméricos)
  // que, en la práctica, no existe en la base. Útil para casos "no encontrado".
  var UUID = Java.type('java.util.UUID');
  return ('' + UUID.randomUUID()).replace(/-/g, '').substring(0, 16);
}
