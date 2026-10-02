@usuarios @listar
Feature: GET /usuarios - Listado y filtros de usuarios

  Como consumidor de la API de ServeRest
  Quiero listar y filtrar usuarios
  Para encontrar rápidamente la información que necesito

  Background:
    * url baseUrl
    * def idsParaLimpiar = []
    * configure afterScenario = limpiarUsuarios
    # Dato de prueba propio: un usuario administrador conocido
    * def creado = call read(helpers.crearUsuario)
    * karate.appendTo('idsParaLimpiar', creado.id)
    * def usuario = creado.usuario
    * def usuarioEsperado = karate.merge(usuario, { _id: creado.id })

  @smoke @positivo @contrato
  Scenario: Listar todos los usuarios cumple el contrato
    Given path 'usuarios'
    When method get
    Then status 200
    And match header Content-Type contains 'application/json'
    And match response == schemas.listaUsuarios
    And match response.quantidade == response.usuarios.length
    * def ids = $response.usuarios[*]._id
    And match ids contains creado.id

  @positivo
  Scenario: Filtrar por email devuelve solo el usuario buscado
    Given path 'usuarios'
    And param email = usuario.email
    When method get
    Then status 200
    And match response == { quantidade: 1, usuarios: ['#(usuarioEsperado)'] }

  @positivo
  Scenario: Filtrar por _id devuelve solo el usuario buscado
    Given path 'usuarios'
    And param _id = creado.id
    When method get
    Then status 200
    And match response == { quantidade: 1, usuarios: ['#(usuarioEsperado)'] }

  @positivo
  Scenario: Filtrar por nome devuelve usuarios con ese nombre
    Given path 'usuarios'
    And param nome = usuario.nome
    When method get
    Then status 200
    And match response == schemas.listaUsuarios
    And match each response.usuarios contains { nome: '#(usuario.nome)' }
    * def ids = $response.usuarios[*]._id
    And match ids contains creado.id

  @positivo
  Scenario Outline: Filtrar por administrador = <administrador>
    Given path 'usuarios'
    And param administrador = '<administrador>'
    When method get
    Then status 200
    And match response == schemas.listaUsuarios
    And match each response.usuarios contains { administrador: '<administrador>' }

    Examples:
      | administrador |
      | true          |
      | false         |

  @positivo
  Scenario: Filtros combinados se aplican en conjunto (AND)
    # El usuario de prueba es administrador, por lo que no debe aparecer con administrador=false
    Given path 'usuarios'
    And params { email: '#(usuario.email)', administrador: 'false' }
    When method get
    Then status 200
    And match response == { quantidade: 0, usuarios: [] }

  @positivo
  Scenario: Filtro sin coincidencias devuelve lista vacía
    Given path 'usuarios'
    And param email = 'no.existe.' + idAleatorio() + '@serverest-qa.com'
    When method get
    Then status 200
    And match response == { quantidade: 0, usuarios: [] }

  @negativo
  Scenario Outline: Filtro inválido es rechazado - <caso>
    Given path 'usuarios'
    And param <parametro> = '<valor>'
    When method get
    Then status 400
    And match response == <respuesta>

    Examples:
      | caso                     | parametro     | valor | respuesta                                                     |
      | administrador inválido   | administrador | xyz   | { administrador: "administrador deve ser 'true' ou 'false'" } |
      | parámetro no soportado   | telefono      | 123   | { telefono: 'telefono não é permitido' }                      |
