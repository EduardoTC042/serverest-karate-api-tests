@usuarios @actualizar
Feature: PUT /usuarios/{_id} - Actualización de usuario

  Background:
    * url baseUrl
    * def idsParaLimpiar = []
    * configure afterScenario = limpiarUsuarios

  @smoke @positivo
  Scenario: Actualizar todos los datos de un usuario existente
    * def creado = call read(helpers.crearUsuario)
    * karate.appendTo('idsParaLimpiar', creado.id)
    * def datosNuevos = generarUsuario({ administrador: 'false' })
    Given path 'usuarios', creado.id
    And request datosNuevos
    When method put
    Then status 200
    And match response == { message: '#(msg.registroActualizado)' }

    # Los cambios quedan persistidos y el id no cambia
    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response == karate.merge(datosNuevos, { _id: creado.id })

  @positivo
  Scenario: Actualizar solo el nombre conservando el mismo email
    * def creado = call read(helpers.crearUsuario)
    * karate.appendTo('idsParaLimpiar', creado.id)
    * def datosNuevos = karate.merge(creado.usuario, { nome: 'Nombre Actualizado QA' })
    Given path 'usuarios', creado.id
    And request datosNuevos
    When method put
    Then status 200
    And match response.message == msg.registroActualizado

    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response.nome == 'Nombre Actualizado QA'
    And match response.email == creado.usuario.email

  @positivo
  Scenario: PUT sobre un id inexistente registra un usuario nuevo (upsert)
    * def idInexistente = idAleatorio()
    * def datos = generarUsuario()
    Given path 'usuarios', idInexistente
    And request datos
    When method put
    Then status 201
    And match response == schemas.mensajeConId
    And match response.message == msg.registroCreado
    * def idNuevo = response._id
    * karate.appendTo('idsParaLimpiar', idNuevo)

    # La API genera su propio id, no reutiliza el de la URL
    Given path 'usuarios', idNuevo
    When method get
    Then status 200
    And match response == karate.merge(datos, { _id: idNuevo })

  @negativo
  Scenario: No se permite actualizar con un email que usa otro usuario
    * def primero = call read(helpers.crearUsuario)
    * def segundo = call read(helpers.crearUsuario)
    * karate.appendTo('idsParaLimpiar', primero.id)
    * karate.appendTo('idsParaLimpiar', segundo.id)
    * def datos = karate.merge(segundo.usuario, { email: primero.usuario.email })
    Given path 'usuarios', segundo.id
    And request datos
    When method put
    Then status 400
    And match response == { message: '#(msg.emailEnUso)' }

    # El usuario no fue modificado
    Given path 'usuarios', segundo.id
    When method get
    Then status 200
    And match response.email == segundo.usuario.email

  @negativo @data-driven
  Scenario Outline: Validación de datos al actualizar - <caso>
    * def creado = call read(helpers.crearUsuario)
    * karate.appendTo('idsParaLimpiar', creado.id)
    * def datos = karate.merge(creado.usuario, valores)
    * if (omitir) karate.remove('datos', '$.' + omitir)
    Given path 'usuarios', creado.id
    And request datos
    When method put
    Then status 400
    And match response == respuestaEsperada

    Examples:
      | read('classpath:com/serverest/common/data/usuarios-invalidos.json') |
