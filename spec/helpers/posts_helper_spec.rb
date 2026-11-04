require "rails_helper"

RSpec.describe PostsHelper, type: :helper do
  it "renders Textile to HTML" do
    expect(helper.render_textile("Some *bold* text")).to eq("<p>Some <strong>bold</strong> text</p>")
  end

  it "keeps the video embeds and inline styles used by existing posts" do
    html = helper.render_textile(<<~TEXTILE)
      p{text-align:center;}. Centered

      <video width="570" height="320" controls="controls"><source src="https://example.com/a.mp4" type="video/mp4"></video>
    TEXTILE

    expect(html).to include('style="text-align:center;"')
    expect(html).to include('<video width="570" height="320" controls="controls">')
    expect(html).to include('<source src="https://example.com/a.mp4" type="video/mp4">')
  end

  it "strips scripts and javascript: links" do
    html = helper.render_textile('<script>alert(1)</script><a href="javascript:alert(1)" onclick="x">hi</a>')
    expect(html).not_to include("script")
    expect(html).not_to include("onclick")
    expect(html).not_to include("javascript:")
  end
end
