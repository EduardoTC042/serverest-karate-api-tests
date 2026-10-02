@usuarios @eliminar
Feature: DELETE /usuarios/{_id} - Eliminación de usuario

  Background:
    * url baseUrl
    * def idsParaLimpiar = []
    * configure afterScenario = limpiarUsuarios

  @smoke @positivo
  Scenario: Eliminar un usuario existente
    * def creado = call read(helpers.crearUsuario)
    * karate.appendTo('idsParaLimpiar', creado.id)
    Given path 'usuarios', creado.id
    When method delete
    Then status 200
    And match response == { message: '#(msg.registroEliminado)' }

    # Ya no puede consultarse
    Given path 'usuarios', creado.id
    When method get
    Then status 400
    And match response == { message: '#(msg.usuarioNoEncontrado)' }

  @negativo
  Scenario: Eliminar un id inexistente no elimina ningún registro
    Given path 'usuarios', idAleatorio()
    When method delete
    Then status 200
    And match response == { message: '#(msg.ningunRegistroEliminado)' }

  @negativo
  Scenario: Eliminar dos veces el mismo usuario es idempotente
    * def creado = call read(helpers.crearUsuario)
    * karate.appendTo('idsParaLimpiar', creado.id)
    Given path 'usuarios', creado.id
    When method delete
    Then status 200
    And match response.message == msg.registroEliminado

    Given path 'usuarios', creado.id
    When method delete
    Then status 200
    And match response.message == msg.ningunRegistroEliminado

  @negativo @integracion
  Scenario: No se permite eliminar un usuario que tiene un carrito registrado
    # Arrange: usuario administrador autenticado, con un producto en su carrito
    * def creado = call read(helpers.crearUsuario)
    * karate.appendTo('idsParaLimpiar', creado.id)
    * def auth = call read(helpers.login) { email: '#(creado.usuario.email)', password: '#(creado.usuario.password)' }
    * def producto = { nome: '#("Producto QA " + idAleatorio())', preco: 100, descricao: 'Producto de prueba automatizada', quantidade: 5 }

    Given path 'produtos'
    And header Authorization = auth.token
    And request producto
    When method post
    Then status 201
    * def idProducto = response._id

    Given path 'carrinhos'
    And header Authorization = auth.token
    And request { produtos: [ { idProduto: '#(idProducto)', quantidade: 1 } ] }
    When method post
    Then status 201
    * def idCarrito = response._id

    # Act
    Given path 'usuarios', creado.id
    When method delete

    # Assert
    Then status 400
    And match response == { message: '#(msg.usuarioConCarrito)', idCarrinho: '#(idCarrito)' }

    # Limpieza: cancelar la compra (repone stock) y eliminar el producto
    Given path 'carrinhos', 'cancelar-compra'
    And header Authorization = auth.token
    When method delete
    Then status 200

    Given path 'produtos', idProducto
    And header Authorization = auth.token
    When method delete
    Then status 200
