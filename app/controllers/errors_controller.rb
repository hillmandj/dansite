# Error pages. config.exceptions_app routes errors here by status code:
# 404s get the playful React page, everything else gets the static page
# from public/ with the real status (so a 422 or 500 is never mislabeled).
class ErrorsController < InertiaController
  def not_found
    path = request.env["action_dispatch.original_path"] || request.path

    respond_to do |format|
      format.html do
        inertia_meta.add([ { title: "Not found · #{SITE_NAME}" }, { name: "robots", content: "noindex" } ])
        render inertia: "errors/not_found", props: { path: path }, status: :not_found
      end
      format.any { head :not_found }
    end
  end

  def show
    code = params[:code].to_i
    page = Rails.public_path.join("#{code}.html")
    page = Rails.public_path.join("500.html") unless page.exist?

    respond_to do |format|
      format.html { render file: page, layout: false, status: code }
      format.any { head code }
    end
  end
end
