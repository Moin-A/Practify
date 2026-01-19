class HeaderComponent < ApplicationComponent
  def initialize(title: nil, subtitle: nil)
    @title = title
    @subtitle = subtitle || I18n.t("practice_overview_title")
  end
end
