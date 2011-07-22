module ApplicationHelper

  def show_errors(model)
    rv = ""
    all_errors = model.errors.full_messages
    if all_errors.any?
      rv = "<div id=\"error_explanation\"><h2>#{pluralize(all_errors.size, "error")} prohibited this #{model.class.to_s.downcase} from being saved:</h2><ul>"
      all_errors.each do |msg|
        rv = rv +"<li>#{msg}</li>"
      end
      rv = rv + "</ul></div"
    end
    rv.html_safe
  end

  def can_edit?(owner)
    return false if current_person.nil?

    return true if (current_person.admin || current_person == owner)
  end

  def paginated_showing_info(collection, name_of_collection)
    "Showing %s of %s"%[collection.count,
                        pluralize(collection.total_entries, name_of_collection)]
  end

  def nl2br(string)
	  string.gsub(/\n/, '<br />') if string
  end

  def url_for(options = nil)
    if Hash === options
      # change all links to use 'http' protocol unless specified
      options[:protocol] ||= 'http'
    end
    super(options)
  end

end
