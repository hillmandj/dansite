require "rails_helper"

RSpec.describe Markdown do
  it "renders Markdown with smart punctuation" do
    expect(described_class.render(%(Some **bold** and "quoted" text -- yes))).to eq(
      "<p>Some <strong>bold</strong> and “quoted” text – yes</p>\n"
    )
  end

  it "keeps the video embeds and images used by existing posts" do
    html = described_class.render(<<~MD)
      <video controls preload="metadata" src="https://example.com/a.mp4"></video>

      ![](https://example.com/a.png)
    MD

    expect(html).to include('<video controls="" preload="metadata" src="https://example.com/a.mp4"></video>')
    expect(html).to include('<img src="https://example.com/a.png" alt="">')
  end

  it "strips scripts, event handlers and javascript: links" do
    html = described_class.render(%(<script>alert(1)</script><a href="javascript:alert(1)" onclick="x">hi</a>\n\n[x](javascript:alert(1))))
    expect(html).not_to include("<script")
    expect(html).not_to include("onclick")
    expect(html).not_to include("javascript:")
  end

  it "extracts plain text" do
    expect(described_class.text("# Title\n\nSome *text*.")).to eq("Title Some text.")
  end
end
