module Admin
  class SettingsController < BaseController
    LABELS = { "show_heatmap" => "GitHub activity", "show_writing" => "Writing section" }.freeze

    def update
      changes = params.require(:settings).permit(*LABELS.keys)
      SiteSetting.current.update!(changes)

      notice = changes.to_h.map { |key, value|
        "#{LABELS[key]} #{ActiveModel::Type::Boolean.new.cast(value) ? 'shown' : 'hidden'} on the home page"
      }.to_sentence
      redirect_to admin_root_path, notice: notice.presence
    end
  end
end
