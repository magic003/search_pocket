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

  def paginate(total, per_page)
    pages = total / per_page + (total % per_page == 0 ? 0 : 1)
    pages = 10 if pages > 10  # only show the first 10 pages
    if pages > 1
      1.upto pages do |p|
        yield p
      end
    end
  end
end
