module SearchHelper
  def best_hit_description(hit, field_name)
    text = nil
    if highlight = hit.highlight(field_name)
      if(!highlight.nil?)
        text = highlight.format { |fragment| content_tag(:strong, fragment) }
        # TODO: strip html from the text variable above, but leave the strong tag for highlighting
      end
    else
      text = hit.result.method(field_name).call
    end

    if(!text.nil?)
      text = text.gsub(/<\/?[^>]*>/, "")
    end

    raw(truncate(text, :length => 150))
  end
end
