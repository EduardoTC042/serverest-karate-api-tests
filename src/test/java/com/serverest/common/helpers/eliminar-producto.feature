@ignore
Feature: Helper - Eliminar producto

  Scenario: Eliminar producto de prueba
    Given url baseUrl
    And path 'produtos', id
    And header Authorization = token
    When method delete
    Then status 200
