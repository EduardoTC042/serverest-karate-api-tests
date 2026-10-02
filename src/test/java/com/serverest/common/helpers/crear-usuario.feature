@ignore
Feature: Helper - Crear usuario

  # Reutilizable: crea un usuario y devuelve { usuario, id }.
  # Uso: * def creado = call read(helpers.crearUsuario)
  #      * def creado = call read(helpers.crearUsuario) { nuevoUsuario: '#(miPayload)' }

  Scenario: Crear usuario por API
    * def usuario = karate.get('nuevoUsuario') || generarUsuario()
    Given url baseUrl
    And path 'usuarios'
    And request usuario
    When method post
    Then status 201
    And match response == schemas.mensajeConId
    * def id = response._id
