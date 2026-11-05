require "rails_helper"

RSpec.describe "Admin image uploads", type: :request do
  let(:s3) { Aws::S3::Client.new(stub_responses: true) }
  let(:image) { fixture_file_upload("pixel.png", "image/png") }

  before do
    ImageUpload.client = s3
    allow(ImageUpload).to receive(:configured?).and_return(true)
  end

  after { ImageUpload.client = nil }

  it "requires login" do
    post "/admin/images", params: { image: image }
    expect(response).to redirect_to(new_user_session_path)
    expect(s3.api_requests).to be_empty
  end

  describe "signed in" do
    before { sign_in create(:user) }

    it "uploads to S3 as a public, long-cached image and returns its URL" do
      travel_to(Time.zone.local(2026, 11, 6)) { post "/admin/images", params: { image: image } }

      expect(response).to have_http_status(:ok)
      url = response.parsed_body["url"]
      expect(url).to match(%r{\Ahttps://dansite-assets\.s3\.amazonaws\.com/blog-images/uploads/2026/11/pixel-\h{6}\.png\z})

      params = s3.api_requests.last[:params]
      expect(params).to include(bucket: "dansite-assets", content_type: "image/png", acl: "public-read")
      expect(params[:key]).to eq(url.delete_prefix("https://dansite-assets.s3.amazonaws.com/"))
      expect(params[:cache_control]).to include("immutable")
    end

    it "rejects files that aren't really images, whatever their name" do
      post "/admin/images", params: { image: fixture_file_upload("not-an-image.png", "image/png") }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to include("Only JPEG, PNG")
      expect(s3.api_requests).to be_empty
    end

    it "rejects images over the size limit" do
      stub_const("ImageUpload::MAX_BYTES", 10)
      post "/admin/images", params: { image: image }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to include("or smaller")
    end

    it "explains when S3 refuses the upload" do
      s3.stub_responses(:put_object, "AccessDenied")
      post "/admin/images", params: { image: image }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to eq("S3 rejected the upload (AccessDenied).")
    end

    it "explains when uploads aren't configured" do
      allow(ImageUpload).to receive(:configured?).and_return(false)
      post "/admin/images", params: { image: image }

      expect(response.parsed_body["error"]).to include("bin/rails aws:configure")
    end
  end
end
