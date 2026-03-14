class ClientResource < Note
  has_rich_text :content
  has_one_attached :cover_image

  def self.default_scope
    where(category: "resource")
  end

  before_validation :set_default_category, on: :create

  private

  def set_default_category
    self.category ||= "resource"
  end
end
