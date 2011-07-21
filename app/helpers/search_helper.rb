module SearchHelper
  def best_hit_description(hit, field_name)
    if highlight = hit.highlight(field_name)
      raw(highlight.format { |fragment| content_tag(:strong, fragment) })
    else
      raw hit.result.method(field_name).call
    end
  end
end
