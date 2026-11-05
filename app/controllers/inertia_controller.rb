# Base class for pages rendered with React via Inertia.
# See https://inertia-rails.dev/guide/shared-data for sharing data with every page.
class InertiaController < ApplicationController
  SITE_NAME = "Daniel Hillman".freeze

  layout "inertia"

  # Every page knows whether the admin is signed in (to show the admin bar).
  inertia_share admin: -> { user_signed_in? }

  private

  # Title, description and Open Graph tags, rendered on the server so link
  # previews (Slack, LinkedIn, iMessage) work without running JavaScript.
  def set_meta(title: nil, description:, path: request.path, type: "website")
    full_title = title ? "#{title} · #{SITE_NAME}" : SITE_NAME
    url = "#{request.base_url}#{path}"

    inertia_meta.add([
      { title: full_title },
      { name: "description", content: description },
      { property: "og:site_name", content: SITE_NAME },
      { property: "og:type", content: type },
      { property: "og:title", content: title || SITE_NAME },
      { property: "og:description", content: description },
      { property: "og:url", content: url },
      { property: "og:image", content: "#{request.base_url}/og-image.jpg" },
      { name: "twitter:card", content: "summary" },
      { tag_name: "link", rel: "canonical", href: url, head_key: "canonical" }
    ])
  end
end
