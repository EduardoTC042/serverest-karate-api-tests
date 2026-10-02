@usuarios @consultar
Feature: GET /usuarios/{_id} - Consulta de usuario por id

  Background:
    * url baseUrl
    * def idsParaLimpiar = []
    * configure afterScenario = limpiarUsuarios

  @smoke @positivo @contrato
  Scenario: Consultar un usuario existente devuelve sus datos
    * def creado = call read(helpers.crearUsuario)
    * karate.appendTo('idsParaLimpiar', creado.id)
    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response == schemas.usuario
    And match response == karate.merge(creado.usuario, { _id: creado.id })

  @negativo
  Scenario: Consultar un id con formato válido que no existe
    Given path 'usuarios', idAleatorio()
    When method get
    Then status 400
    And match response == { message: '#(msg.usuarioNoEncontrado)' }

  @negativo
  Scenario Outline: Consultar con id de formato inválido - <caso>
    Given path 'usuarios', '<id>'
    When method get
    Then status 400
    And match response == { id: '#(msg.idInvalido)' }

    Examples:
      | caso                    | id                |
      | menos de 16 caracteres  | 123               |
      | más de 16 caracteres    | abcdefghijklmnopq |
      | caracteres especiales   | abc-defghijklmno  |
