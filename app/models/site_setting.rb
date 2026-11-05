# Site-wide switches edited in the admin. There is only ever one row.
class SiteSetting < ApplicationRecord
  def self.current
    first || create!
  end

  def as_props
    { show_heatmap:, show_writing: }
  end
end
