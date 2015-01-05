Feature: Manage Posts
  In order to have a blog
  As a user
  I want to view and create posts

  Scenario: Posts List
    Given I have posts titled FirstPost, SecondPost
    When I go to the posts list
    Then I should see "FirstPost"
    And I should see "SecondPost"

  Scenario: Add Post
    Given I login successfully
    When I go to the posts list
    Then I should see "Add Post"
    When I click "Add Post"
    And I fill in the post form with "title, content"
    And I press "Submit"
    When I go to the posts list
    Then I should see "title"
