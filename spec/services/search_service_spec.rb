require 'spec_helper'

# A mock for the Search service.
# WebMock requires us to know which URLs are called from within the gem.
# Is it better to mock the API interface or mock the API internals?
# This approach mocks the API.
class MockSearch
  def initialize(json)
    @json = json
  end

  def objectify(opts = {})
    return Array[self]
  end

  def marshal_dump
    SearchService.parse_raw(@json)
  end
end

describe SearchService do

  describe "SearchService#fetch_results(params, models)" do

    context "Success" do

      before(:each) do
        @mock_search = mock('search')
        @search = SearchService.new(@mock_search)
      end

      it "should pass all options through to Search" do
        params = Hash.new
        params[:q] = "Town"

        @mock_search.should_receive(:search).with([Conversation]).and_return(@mock_search)
        @mock_search.should_receive(:each_hit_with_result).and_return([])
        @search.fetch_results(params, Conversation).should == []
      end

      it "should return an empty set of results" do
        @mock_search.should_receive(:search).and_return(@mock_search)
        @mock_search.should_receive(:each_hit_with_result).and_return([])
        @search.fetch_results().should == []
      end
    end
  end
=begin
    context "Success" do

      it "should pass all options through to Embedly" do

        url = 'http://www.youtube.com/watch?v=onUd7aZhu9g'
        opts = {
          :maxwidth => 100,
          :maxheight => 100,
        }

        mock_embedly = mock('embedly')
        mock_embedly.should_receive(:objectify).once.with(hash_including({url: url}))

        embedly = EmbedlyService.new(mock_embedly)
        embedly.fetch(url, opts)

      end

      it "retrieve embedly object given a valid YouTube url" do

        # These two lines use our internal mock
        json = fixture_content('embedly/youtube.json')
        embedly = EmbedlyService.new(MockEmbedly.new(json))

        # This line uses WebMock
        #embedly = EmbedlyService.new

        embedly.fetch('http://www.youtube.com/watch?v=onUd7aZhu9g')

        embedly.error.should be_nil
        embedly.properties.should_not be_nil

        embedly.properties.should have_key(:original_url)
        embedly.properties[:original_url].should == 'http://www.youtube.com/watch?v=onUd7aZhu9g'
        embedly.properties.should have_key(:url)
        embedly.properties[:url].should == 'http://www.youtube.com/watch?v=onUd7aZhu9g'
        embedly.properties.should have_key(:oembed)
        embedly.properties[:oembed].should be_instance_of Hash
      end

      describe "EmbedlyService#fetch_ane_update_attributes(contribution)" do

        before(:each) do
          @contribution = Factory.create(:contribution, type: 'Link', url: 'http://www.youtube.com/watch?v=ukuERsvfDMU')
          @embedly = EmbedlyService.new
          @boolean = @embedly.fetch_and_update_attributes(@contribution)
        end

        it "returns true if able to connect and retrieve information from embed.ly" do
          @boolean.should be_true
        end

      end

    end

  end

  describe "EmbedltService#parse_raw(data)" do

    it "should properly parse data from an EmbedlyContribution" do
      contrib = Factory.build(:embedly_contribution)
      contrib.embedly_code = fixture_content('embedly/flickr.json')
      data = EmbedlyService.parse_raw(contrib)
      data.should_not be_empty
      data.should have_key(:embeds)

      embedly = EmbedlyService.new.load(contrib)
      embedly.properties.should_not be_empty
      embedly.properties.should have_key(:embeds)
    end
  end
=end 
end
