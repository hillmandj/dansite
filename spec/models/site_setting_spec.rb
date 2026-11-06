require "rails_helper"

RSpec.describe SiteSetting do
  it "defaults to the Solarized theme" do
    expect(described_class.current.site_theme).to eq("solarized")
  end

  it "only accepts known themes" do
    expect(described_class.current.update(site_theme: "nope")).to be(false)
  end

  it "falls back to the default theme if the stored one no longer exists" do
    described_class.current.update_column(:site_theme, "retired")
    expect(described_class.theme).to eq("solarized")
  end
end
