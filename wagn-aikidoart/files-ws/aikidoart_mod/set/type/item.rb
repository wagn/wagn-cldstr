view :thumbnail do |args|
  wrap args do
    text = subformat( Card["#{card.name}+#{ Card[:image].name }"] ).render_core :size=>:medium
    card_link card.name, text, true
  end
end