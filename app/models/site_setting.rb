# Site-wide switches edited in the admin. There is only ever one row.
class SiteSetting < ApplicationRecord
  # Themes the admin can pick. Each key matches a block in app/frontend/entrypoints/themes.css.
  # `bg` is the dark background, used for the browser's theme-color.
  THEMES = {
    "solarized" => { label: "Solarized", bg: "#0e1c20" },
    "gruvbox" => { label: "Gruvbox", bg: "#282828" },
    "catppuccin" => { label: "Catppuccin", bg: "#1e1e2e" },
    "classic" => { label: "Classic", bg: "#0a0f1a" }
  }.freeze

  validates :site_theme, inclusion: { in: THEMES.keys }

  def self.current
    first || create!
  end

  # The theme to render, falling back to the default if the stored one was removed.
  def self.theme
    theme = current.site_theme
    THEMES.key?(theme) ? theme : THEMES.keys.first
  end

  def as_props
    { show_heatmap:, show_writing: }
  end
end
