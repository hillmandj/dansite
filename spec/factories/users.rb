FactoryGirl.define do
  factory :user do
    email 'test@example.com'
    password 'password'    
  end

  factory :admin, :class => User do
    email 'admin@example.com'
    password 'password'
    admin true
  end
end
