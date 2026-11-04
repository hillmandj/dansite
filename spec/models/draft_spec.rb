require "rails_helper"

RSpec.describe Draft, type: :model do
  it "requires a title and content" do
    expect(build(:draft)).to be_valid
    expect(build(:draft, title: "")).not_to be_valid
    expect(build(:draft, content: "")).not_to be_valid
  end
end
