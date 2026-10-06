@ignore
Feature: Helper - Cancelar carrito de compra

  Scenario: Cancelar la compra del usuario autenticado
    Given url baseUrl
    And path 'carrinhos', 'cancelar-compra'
    And header Authorization = token
    When method delete
    Then status 200
