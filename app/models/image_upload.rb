require "aws-sdk-s3"

# Uploads an image for a blog post to the dansite-assets S3 bucket and returns
# its permanent public URL (the same place the older post images live).
#
# Credentials live in Rails credentials under `aws:` (set them with
# `bin/rails aws:configure`). Bucket and region are not secret.
class ImageUpload
  BUCKET = "dansite-assets".freeze
  REGION = "us-east-1".freeze
  PREFIX = "blog-images/uploads".freeze
  MAX_BYTES = 10.megabytes
  TYPES = {
    "image/jpeg" => "jpg", "image/png" => "png", "image/gif" => "gif",
    "image/webp" => "webp", "image/avif" => "avif"
  }.freeze

  class Error < StandardError; end

  class << self
    attr_writer :client

    def configured?
      credentials.present? && credentials[:access_key_id].present? && credentials[:secret_access_key].present?
    end

    def client
      @client ||= Aws::S3::Client.new(
        region: REGION,
        access_key_id: credentials.fetch(:access_key_id),
        secret_access_key: credentials.fetch(:secret_access_key)
      )
    end

    def public_url(key)
      "https://#{BUCKET}.s3.amazonaws.com/#{key}"
    end

    private

    def credentials
      Rails.application.credentials.aws
    end
  end

  def initialize(file)
    @file = file
  end

  # => "https://dansite-assets.s3.amazonaws.com/blog-images/uploads/2026/11/photo-1a2b3c.png"
  def upload!
    raise Error, "Image uploads aren't set up yet (run bin/rails aws:configure)." unless self.class.configured?
    raise Error, "Images must be #{MAX_BYTES / 1.megabyte} MB or smaller." if @file.size > MAX_BYTES

    # Trust the file's bytes, not its name or the browser's claimed type.
    content_type = Marcel::MimeType.for(@file.tempfile)
    extension = TYPES[content_type] or raise Error, "Only JPEG, PNG, GIF, WebP and AVIF images are supported."

    key = "#{PREFIX}/#{Time.current.strftime('%Y/%m')}/#{basename}-#{SecureRandom.hex(3)}.#{extension}"
    @file.tempfile.rewind
    self.class.client.put_object(
      bucket: BUCKET,
      key: key,
      body: @file.tempfile,
      content_type: content_type,
      cache_control: "public, max-age=31536000, immutable",
      acl: "public-read"
    )
    self.class.public_url(key)
  rescue Aws::Errors::ServiceError => e
    Rails.logger.error("[ImageUpload] #{e.class}: #{e.message}")
    raise Error, "S3 rejected the upload (#{e.code})."
  end

  private

  def basename
    File.basename(@file.original_filename.to_s, ".*").parameterize.first(60).presence || "image"
  end
end
