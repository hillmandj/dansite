Feature: Manage Posts
  In order to have a blog
  As a user
  I want to view and create posts

  Scenario: Posts List
    Given I have posts titled FirstPost, SecondPost
    When I go to the posts list
    Then I should see "FirstPost"
    And I should see "SecondPost"
