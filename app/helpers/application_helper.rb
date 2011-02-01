module ApplicationHelper
  # Title hepler, used in all views
  def title(page_title)
      content_for(:title) { page_title }
  end
end
