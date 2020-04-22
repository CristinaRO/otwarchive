@users
Feature: User activation

Scenario: User activates then logs in
  Given the following users exist
    | login    | password | confirmation_token |
    | sam      | secret   | abc123             |
    When I activate my account with the token "abc123"
    Then I should see "Account activation complete! Please log in."
    When I follow "Log In"
      And I fill in "User name or email:" with "sam"
      And I fill in "Password:" with "secret"
      And I press "Log In"
    Then I should not see "already been activated"
