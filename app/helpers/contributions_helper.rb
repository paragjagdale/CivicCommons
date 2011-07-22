module ContributionsHelper
  def contribution_parent_page(contribution)
    if contribution.conversation
      conversation_path(contribution.conversation)
    else
      issue_path(contribution.issue)
    end
  end

  def person_display_name(person)
    if person
      text_profile(person).html_safe
    else
      'An unknown person'
    end
  end
end
