class Api::ContributedConversations

  def self.for_person_by_email(email)
    person = Person.find_by_email(email)
    for_person(person)
  end


  def self.for_person(person)
    conversations = person.contributed_conversations

    conversations.map do |conversation|
      {
        title: conversation.title,
        image: conversation.image.url,
        summary: conversation.summary,
        participant_count: conversation.participants.count,
        contribution_count: conversation.contributions.where(owner: person).count
      }
    end
  end

end
