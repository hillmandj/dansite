Given(/^I have posts titled (.+)$/) do |titles|
  titles.split(',').each do |title|
    Post.create!(:title => title, :content => Forgery(:lorem_ipsum).words(20))
  end
end

When(/^I go to the posts list$/) do
  visit posts_path
end

Then(/^I should see "(.*?)"$/) do |arg1|
  expect(page).to have_content(arg1)
end
