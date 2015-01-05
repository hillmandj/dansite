Given(/^I have posts titled (.+)$/) do |titles|
  titles.split(',').each do |title|
    Post.create!(:title => title, :content => Forgery(:lorem_ipsum).words(20))
  end
end

Given(/^I login successfully$/) do
  step 'I go to the posts list'
  admin = FactoryGirl.create(:admin)
  click_link 'Login'
  fill_in 'Email', :with => admin.email
  fill_in 'Password', :with => admin.password
  click_button 'Sign in'
end

When(/^I go to the posts list$/) do
  visit posts_path
end

When(/^I click "(.*?)"$/) do |link_name|
  click_link "#{link_name}"
end

When(/^I press "(.*?)"$/) do |btn_name|
  click_button "#{btn_name}"
end

When(/^I fill in the post form with "(.*?)"$/) do |post_inputs|
  post_inputs = post_inputs.split(',')
  within '#new_post' do
    fill_in 'post[title]', :with => post_inputs.first
    fill_in 'post[content]', :with => post_inputs.last
  end
end

Then(/^I should see "(.*?)"$/) do |text|
  expect(page).to have_content(text)
end
