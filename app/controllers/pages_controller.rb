class PagesController < InertiaController
  HOME_POSTS = 5
  # Posts linked from the "Off the clock" paragraph.
  HOBBY_POSTS = %w[my-top-five-graphic-novels memoirs-of-a-fantasy-champion].freeze

  def home
    set_meta(
      description: "Daniel Hillman is a Staff Software Engineer at Zendesk who builds web apps, " \
                   "developer tools and the infrastructure underneath them.",
      path: root_path
    )
    settings = SiteSetting.current
    render inertia: "home/index", props: {
      posts: Post.published.newest_first.limit(HOME_POSTS).map { |post|
        { title: post.title, slug: post.slug, date: post.date.iso8601 }
      },
      more_posts: Post.published.count > HOME_POSTS,
      hobby_posts: Post.published.where(slug: HOBBY_POSTS).pluck(:slug),
      contributions: settings.show_heatmap ? GithubContributions.current : nil,
      settings: settings.as_props
    }
  end
end
