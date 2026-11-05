FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    admin { true }
  end

  factory :post do
    sequence(:title) { |n| "Post number #{n}" }
    content { "Some *Markdown* content." }
    published_at { 1.day.ago }

    trait :draft do
      published_at { nil }
    end
  end

  factory :draft do
    sequence(:title) { |n| "Draft number #{n}" }
    content { "Draft content." }
  end

  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    sequence(:position) { |n| n }
    description { "A project description." }
    site_url { "https://example.com" }
    image_url { nil }
  end
end
