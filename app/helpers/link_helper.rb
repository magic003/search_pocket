module LinkHelper
  def link_title(link)
    if link.given_title.nil? || link.given_title.empty?
      if link.resolved_title.nil? || link.resolved_title.empty?
        link.url
      else
        link.resolved_title
      end
    else
      link.given_title
    end
  end
end
