format :email_html do
  view :missing        do |args| '' end
  view :closed_missing do |args| '' end
end


def clean_html?
  false
end
