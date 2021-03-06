xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'
xml.rss :version => '2.0', 'xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd', 'xmlns:atom' => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.tag!('atom:link', :href => podcast_url(:format => :xml), :rel => "self", :type => "application/rss+xml")
    xml.title 'The Civic Commons Podcast'
    xml.link radioshow_index_url
    xml.description 'The Civic Commons podcast is a dynamic half-hour public affairs program airing Saturday mornings on WJCU (88.7 FM, University Heights), and Tuesday evenings on WYSU (88.5 FM, Youngstown). It features citizen voices more than talking heads, citizen commentaries instead of expert drones, and hosts who are always looking for different ways to set the stage for discussion. Hosted by award-winning public radio host Dan Moulthrop, produced by Luke Frazier of NOW Productions with assistance from WJCU and edited by Daniel Steinberg of Dim Sum Thinking and Erica Brenner of Brenner Productions. The podcast is part of The Civic Commons, a regional effort to bring more citizens into the conversations that matter.'
    xml.copyright "(c) Copyright #{Date.today.strftime('%Y')} The Civic Commons"
    xml.image do
      xml.url "#{root_url}images/cc_podcast.jpg"
      xml.title 'The Civic Commons Podcast'
      xml.link radioshow_index_url
    end
    xml.language 'en-us'
    xml.pubDate Time.now.rfc822
    xml.lastBuildDate Time.now.rfc822
    xml.tag!('itunes:summary', 'The Civic Commons podcast is a dynamic half-hour public affairs program airing Saturday mornings on WJCU (88.7 FM, University Heights), and Tuesday evenings on WYSU (88.5 FM, Youngstown). It features citizen voices more than talking heads, citizen commentaries instead of expert drones, and hosts who are always looking for different ways to set the stage for discussion. Hosted by award-winning public radio host Dan Moulthrop, produced by Luke Frazier of NOW Productions with assistance from WJCU and edited by Daniel Steinberg of Dim Sum Thinking and Erica Brenner of Brenner Productions. The podcast is part of The Civic Commons, a regional effort to bring more citizens into the conversations that matter.')
	xml.tag!('itunes:subtitle', 'Weekly Radio Show Podcast')
	xml.tag!('itunes:author', 'The Civic Commons')
    xml.tag!('itunes:owner') do
      xml.tag!('itunes:name', 'The Civic Commons')
      xml.tag!('itunes:email', 'suggestions@theciviccommons.com')
    end
    xml.tag!('itunes:category', :text => 'News & Politics')
    xml.tag!('itunes:image', :href => "#{root_url}images/cc_podcast.jpg")
	xml.tag!('itunes:explicit', 'No')
    for show in @radioshows
      xml.item do
        xml.title show.title
        xml.link radioshow_url(show)
        xml.guid radioshow_url(show)
        xml.description show.summary
        xml.pubDate show.published.to_s(:rfc822)
        xml.enclosure :url => show.external_link, :length => '17159756', :type =>'audio/mpeg' 
		xml.tag!('itunes:author', 'The Civic Commons')
		xml.tag!('itunes:summary', show.summary)
      end
    end
  end
end
