Feature: User inbox

  In order to receive various notifications
  As a user
  I want to have a functional inbox
  
  Scenario: Inbox for a new user
  
  Given I am logged in as a random user
  When I go to my inbox page
  Then the inbox should be empty
  
  Scenario: Receiving a comment on a work
  
  Given I am logged in as a random user
    And I receive a comment "blabla" on my work "Transformative"
  When I go to my inbox page
  Then I should see a feedback message for the work "Transformative"
  
  Scenario: Receiving a comment on a tag of which I am a wrangler
  
  # Given I am logged in as a tag wrangler
  Given the following activated tag wranglers exist
    | login  | password |
    | myself | password |
    | them   | password |
    And I am logged in as "myself"
    And I am the wrangler of "GhostSoup"
    And "them" posts a comment "You are wrangling it wrong!" on the tag "GhostSoup"
  When I go to my inbox page
  Then I should see a tag wrangling message from "them" on the tag "GhostSoup"
