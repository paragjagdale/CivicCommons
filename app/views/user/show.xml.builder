xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", 'xmlns:atom' => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.tag!('atom:link', :href => user_url(@user, :format => :xml), :rel => "self", :type => "application/rss+xml")
    xml.title "The Civic Commons: #{@user.name}"
    xml.description "Bio: #{@user.bio}"
    xml.copyright "(c) Copyright #{Date.today.strftime('%Y')} The Civic Commons"
    xml.link user_url(@user)
    xml.image do
      xml.url @user.avatar_url
      xml.title "The Civic Commons: #{@user.name}"
      xml.link user_url(@user)
    end
    xml.language "en-us"
    xml.pubDate Time.now.rfc822
    xml.lastBuildDate Time.now.rfc822
    for recent_item in ActivityPresenter.new(@recent_items)
      xml.item do
        if recent_item.is_a?(Conversation)
          xml.title recent_item.title
          xml.link conversation_url(recent_item)
          xml.guid conversation_url(recent_item)
          xml.description recent_item.summary
        elsif recent_item.is_a?(RatingGroup)
          xml.title "#{recent_item.person.name} rated a response from #{recent_item.contribution.person.name} as #{Rating.find_by_rating_group_id(recent_item.id).rating_descriptor.title}"
          xml.link conversation_url(recent_item.contribution.conversation)
          xml.guid conversation_url(recent_item.contribution.conversation)
          xml.description "#{recent_item.contribution.person.name} said '#{recent_item.contribution.content}'"
        elsif recent_item.is_a?(Contribution)
          recent_item = ContributionPresenter.new(recent_item)
          xml.title "#{@user.name} responded to the conversation '#{recent_item.parent_title}'"
          xml.link conversation_node_url(recent_item)
          xml.guid conversation_node_url(recent_item)
          xml.description Sanitize.clean(recent_item.content, :remove_contents => ['script']).strip
        else
          xml.title "#{@user.name} participated in a conversation at The Civic Commons"
          xml.link user_url(@user)
          xml.guid user_url(@user)
          xml.description "#{@user} participated in a conversation at The Civic Commons"
        end
        xml.pubDate recent_item.created_at.to_time.to_formatted_s(:rfc822)
      end
    end
  end
end
