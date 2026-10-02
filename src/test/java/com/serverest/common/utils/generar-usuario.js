function(overrides) {
  // Genera un payload de usuario válido y ÚNICO para ServeRest.
  // - Nombre y password realistas con DataFaker (locale es).
  // - Email con UUID para evitar colisiones en ejecuciones paralelas y en la instancia pública.
  // Uso:  * def usuario = generarUsuario()
  // * def usuario = generarUsuario({ administrador: 'false' })   // sobreescribe campos
  var Faker = Java.type('net.datafaker.Faker');
  var Locale = Java.type('java.util.Locale');
  var UUID = Java.type('java.util.UUID');
  var faker = new Faker(new Locale('es'));
  var unico = ('' + UUID.randomUUID()).replace(/-/g, '').substring(0, 12);
  var usuario = {
    nome: '' + faker.name().fullName(),
    email: 'qa.' + unico + '@serverest-qa.com',
    password: '' + faker.internet().password(8, 16),
    administrador: 'true'
  };
  return karate.merge(usuario, overrides || {});
}
