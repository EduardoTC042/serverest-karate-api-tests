@ignore
Feature: Helper - Login

  # Reutilizable: autentica y devuelve el token Bearer en `token`.
  # Uso: * def auth = call read(helpers.login) { email: '#(u.email)', password: '#(u.password)' }

  Scenario: Obtener token
    Given url baseUrl
    And path 'login'
    And request { email: '#(email)', password: '#(password)' }
    When method post
    Then status 200
    And match response == { message: '#(msg.loginExitoso)', authorization: '#regex Bearer .+' }
    * def token = response.authorization
