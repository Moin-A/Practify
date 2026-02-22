
class PagesController < ApplicationController
  allow_unauthenticated_access only: [:privacy, :terms]

  def about
  end

  def privacy
  end

  def terms
  end
end
