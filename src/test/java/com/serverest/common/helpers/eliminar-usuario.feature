@ignore
Feature: Helper - Eliminar usuario

  # Reutilizable: elimina un usuario por id (idempotente: 200 aunque ya no exista).
  # Uso: * call read(helpers.eliminarUsuario) { id: '#(id)' }

  Scenario: Eliminar usuario por API
    Given url baseUrl
    And path 'usuarios', id
    When method delete
    Then status 200
