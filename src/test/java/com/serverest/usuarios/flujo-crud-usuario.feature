@usuarios @e2e @smoke
Feature: Ciclo de vida completo de un usuario (CRUD end-to-end)

  Background:
    * url baseUrl
    * def idsParaLimpiar = []
    * configure afterScenario = limpiarUsuarios

  Scenario: Registrar, consultar, listar, actualizar y eliminar un usuario
    # 1. Registrar
    * def usuario = generarUsuario()
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 201
    And match response == schemas.mensajeConId
    * def id = response._id
    * karate.appendTo('idsParaLimpiar', id)

    # 2. Consultar por id
    Given path 'usuarios', id
    When method get
    Then status 200
    And match response == karate.merge(usuario, { _id: id })

    # 3. Aparece en el listado filtrado por email
    Given path 'usuarios'
    And param email = usuario.email
    When method get
    Then status 200
    And match response.quantidade == 1
    And match response.usuarios[0]._id == id

    # 4. Actualizar (pasa a ser no administrador)
    * def actualizado = karate.merge(usuario, { nome: 'Usuario E2E Actualizado', administrador: 'false' })
    Given path 'usuarios', id
    And request actualizado
    When method put
    Then status 200
    And match response.message == msg.registroActualizado

    Given path 'usuarios', id
    When method get
    Then status 200
    And match response == karate.merge(actualizado, { _id: id })

    # 5. Eliminar
    Given path 'usuarios', id
    When method delete
    Then status 200
    And match response.message == msg.registroEliminado

    # 6. Ya no existe
    Given path 'usuarios', id
    When method get
    Then status 400
    And match response.message == msg.usuarioNoEncontrado
