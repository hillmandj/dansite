namespace :aws do
  desc "Save the AWS access key used for blog image uploads into encrypted credentials"
  task configure: :environment do
    require "io/console"

    print "AWS access key ID: "
    access_key_id = $stdin.gets.to_s.strip
    print "AWS secret access key (hidden): "
    secret_access_key = $stdin.noecho(&:gets).to_s.strip
    puts

    abort "Both values are required; nothing was changed." if access_key_id.empty? || secret_access_key.empty?

    credentials = Rails.application.credentials
    data = YAML.safe_load(credentials.read.presence || "{}") || {}
    data["aws"] = { "access_key_id" => access_key_id, "secret_access_key" => secret_access_key }
    credentials.write(data.to_yaml)

    puts "Saved to config/credentials.yml.enc (encrypted with config/master.key)."
    puts "Uploads go to s3://#{ImageUpload::BUCKET}/#{ImageUpload::PREFIX}/"
  end

  desc "Upload a tiny test image to S3 and check that it is publicly readable"
  task check: :environment do
    require "net/http"

    abort "No AWS credentials. Run bin/rails aws:configure first." unless ImageUpload.configured?

    png = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=")
    file = Tempfile.new([ "dansite-upload-check", ".png" ], binmode: true)
    file.write(png)
    file.rewind
    upload = ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: "upload-check.png", type: "image/png")

    url = ImageUpload.new(upload).upload!
    status = Net::HTTP.get_response(URI(url)).code
    puts "Uploaded #{url}"
    puts status == "200" ? "Publicly readable: yes (HTTP 200). Uploads are working." : "Publicly readable: NO (HTTP #{status}). See infra/README.md."
  ensure
    file&.close!
  end
end
