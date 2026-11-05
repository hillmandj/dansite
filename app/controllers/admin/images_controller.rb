module Admin
  # Receives an image from the editor (drag, drop, paste or file picker),
  # stores it on S3 and returns the URL to insert into the post.
  class ImagesController < BaseController
    def create
      file = params.require(:image)
      render json: { url: ImageUpload.new(file).upload! }
    rescue ImageUpload::Error => e
      render json: { error: e.message }, status: :unprocessable_content
    end
  end
end
