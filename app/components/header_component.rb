class HeaderComponent < ApplicationComponent
  def initialize(title: nil, subtitle: nil)
    @title = title || "Good morning, Dr Smith"
    @subtitle = subtitle || "Here's your practice overview for today"
  end
end
