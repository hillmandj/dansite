require "rails_helper"

RSpec.describe Project, type: :model do
  it "is valid with the required attributes" do
    expect(build(:project)).to be_valid
  end

  %i[name position description site_url].each do |attr|
    it "requires #{attr}" do
      expect(build(:project, attr => nil)).not_to be_valid
    end
  end

  it "knows whether it has an image" do
    expect(build(:project, image_url: "projects/handy.png")).to have_image
    expect(build(:project, image_url: nil)).not_to have_image
  end
end
