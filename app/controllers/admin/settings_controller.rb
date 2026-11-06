module Admin
  class SettingsController < BaseController
    LABELS = { "show_heatmap" => "GitHub activity", "show_writing" => "Writing section" }.freeze

    def update
      changes = params.require(:settings).permit(*LABELS.keys, :site_theme)
      setting = SiteSetting.current

      if setting.update(changes)
        redirect_to admin_root_path, notice: notice_for(changes.to_h).presence
      else
        redirect_to admin_root_path, alert: setting.errors.full_messages.to_sentence
      end
    end

    private

    def notice_for(changes)
      changes.map { |key, value|
        if key == "site_theme"
          "Site theme set to #{SiteSetting::THEMES.dig(value, :label)}"
        else
          "#{LABELS[key]} #{ActiveModel::Type::Boolean.new.cast(value) ? 'shown' : 'hidden'} on the home page"
        end
      }.to_sentence
    end
  end
end
