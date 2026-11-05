class PagesController < InertiaController
  def home
    set_meta(
      description: "Daniel Hillman is a Staff Software Engineer at Zendesk who builds web apps, " \
                   "developer tools and the infrastructure underneath them.",
      path: root_path
    )
    settings = SiteSetting.current
    render inertia: "home/index", props: {
      posts: Post.published.newest_first.map { |post|
        { title: post.title, slug: post.slug, date: post.date.iso8601 }
      },
      contributions: settings.show_heatmap ? GithubContributions.current : nil,
      settings: settings.as_props
    }
  end
end
