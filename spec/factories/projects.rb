FactoryGirl.define do
  factory :project do
    name "Test Project"
    description { Forgery(:lorem_ipsum).words(20) }
    image_url "test_project.jpg"
  end
end
