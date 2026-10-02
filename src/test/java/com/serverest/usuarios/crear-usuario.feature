@usuarios @crear
Feature: POST /usuarios - Registro de usuarios

  Como consumidor de la API de ServeRest
  Quiero registrar usuarios
  Para que puedan autenticarse y operar en la tienda

  Background:
    * url baseUrl
    * def idsParaLimpiar = []
    * configure afterScenario = limpiarUsuarios

  @smoke @positivo
  Scenario Outline: Registrar un usuario válido con administrador = <administrador>
    * def usuario = generarUsuario({ administrador: '<administrador>' })
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 201
    And match header Content-Type contains 'application/json'
    And match response == schemas.mensajeConId
    And match response.message == msg.registroCreado
    * def id = response._id
    * karate.appendTo('idsParaLimpiar', id)

    # El usuario queda persistido exactamente con los datos enviados
    Given path 'usuarios', id
    When method get
    Then status 200
    And match response == schemas.usuario
    And match response == karate.merge(usuario, { _id: id })

    Examples:
      | administrador |
      | true          |
      | false         |

  @negativo
  Scenario: No se permite registrar un email que ya está en uso
    * def existente = call read(helpers.crearUsuario)
    * karate.appendTo('idsParaLimpiar', existente.id)
    * def duplicado = generarUsuario({ email: existente.usuario.email })
    Given path 'usuarios'
    And request duplicado
    When method post
    * if (responseStatus == 201) karate.appendTo('idsParaLimpiar', response._id)
    Then status 400
    And match response == schemas.mensaje
    And match response == { message: '#(msg.emailEnUso)' }

  @negativo
  Scenario: Registrar con body vacío informa todos los campos obligatorios
    Given path 'usuarios'
    And request {}
    When method post
    Then status 400
    And match response ==
      """
      {
        nome: 'nome é obrigatório',
        email: 'email é obrigatório',
        password: 'password é obrigatório',
        administrador: 'administrador é obrigatório'
      }
      """

  @negativo @data-driven
  Scenario Outline: Validación de datos al registrar - <caso>
    * def usuario = generarUsuario(valores)
    * if (omitir) karate.remove('usuario', '$.' + omitir)
    Given path 'usuarios'
    And request usuario
    When method post
    # Si la API aceptara el payload por error, se limpia igual el usuario creado
    * if (responseStatus == 201) karate.appendTo('idsParaLimpiar', response._id)
    Then status 400
    And match response == respuestaEsperada

    Examples:
      | read('classpath:com/serverest/common/data/usuarios-invalidos.json') |
