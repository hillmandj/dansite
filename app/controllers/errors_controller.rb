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
end
