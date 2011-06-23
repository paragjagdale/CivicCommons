class EmbedlyService

  # http://embed.ly/
  # https://pro.embed.ly/
  # http://explore.embed.ly/
  # http://api.embed.ly/

  attr_reader :properties
  attr_reader :error
  attr_reader :error_code

  def initialize(embedly = nil)
    clear_state
    if embedly.nil?
      @embedly = Embedly::API.new(key: Civiccommons::Config.embedly['key'])
    else
      @embedly = embedly
    end
  end

  def fetch(url, opts = {})
    clear_state
    opts[:url] = url.strip
    opts[:wmode] = 'opaque'
    objs = @embedly.objectify(opts)
    @properties = objs[0].marshal_dump
    raise @properties[:error_message] if @properties.has_key?(:error_message)
  rescue => error
    @error = error.message
    if not @properties.nil? and @properties.has_key?(:error_code)
      @error_code = @properties[:error_code].to_i
    else
      @error_code = 500
      @error = "Server Issues"
    end
    @properties = nil
    Rails.logger.error error.message
  end

  def fetch_and_merge_params!(params)
    fetch(params[:contribution][:url])
    unless properties.nil?
      if properties[:type] == 'html' and not properties[:oembed].empty?
        params[:contribution][:embedly_type] = properties[:oembed][:type]
      else
        params[:contribution][:embedly_type] = properties[:type]
      end
      params[:contribution][:embedly_code] = raw
      params[:contribution][:url] = properties[:url]
      params[:contribution][:title] = properties[:title] unless properties[:title].blank?
      if params[:description].blank? and not properties[:title].blank?
        params[:contribution][:description] = properties[:description]
      end
    end
    return (not properties.nil?)
  end

  def fetch_and_update_attributes(contribution)
    fetch(contribution.url)
    unless contribution.type == "EmbedlyContribution"
      contribution.type = "EmbedlyContribution"
    end
    unless properties.nil?
      if properties[:type] == 'html' and not properties[:oembed].empty?
        contribution.embedly_type = properties[:oembed][:type]
        contribution.embed_target = nil
      else
        contribution.embedly_type = properties[:type]
      end
      contribution.embedly_code = raw
      contribution.url = properties[:url]
      contribution.title = properties[:title] unless properties[:title].blank?
      unless  properties[:title].blank?
        contribution.description = properties[:description]
      end
    end
    return (not properties.nil?)
  end

  ### Error Code Convenience Methods

  def ok?
    @error_code == 200
  end

  def bad_request?
    @error_code == 400
  end

  def forbidden?
    @error_code == 403
  end

  def not_found?
    @error_code == 404
  end

  def server_issues?
    @error_code == 500
  end

  def not_implemented?
    @error_code == 501
  end

  def raw
    @properties.to_json
  end

  ### Utility Methods

  def load(data)
    @properties = EmbedlyService.parse_raw(data)
    return self
  end

  def self.parse_raw(data)

    if not data.is_a?(Hash)
      data = data.embedly_code if data.is_a?(EmbedlyContribution)
      begin
        data = JSON.parse(data)
      rescue JSON::ParserError 
        data = {}
      end
    end

    data.keys.each do |key|
      if not key.is_a?(Symbol)
        new_key = key.to_sym
        data[new_key] = data[key]
        data.delete(key)
        if data[new_key].is_a?(Hash)
          data[new_key] = self.parse_raw(data[new_key])
        elsif data[new_key].is_a?(Array)
          data[new_key].each do |element|
            element = self.parse_raw(element)
          end
        end
      end
    end

    return data
  end

  def self.get_simple_embed(url, max_embed_width = nil)
    embed = nil
    service = EmbedlyService.new
    service.fetch(url)
    embed = service.to_embed_or_fancybox(max_embed_width) if service.ok?
    return embed
  end

  def to_embed_or_fancybox(max_embed_width = nil)
    EmbedlyService.to_embed_or_fancybox(properties, max_embed_width)
  end

  def self.to_embed_or_fancybox(code, max_embed_width = nil)

    html = nil
    code = self.parse_raw(code) 

    # link type always generates linked thumbnail
    if code[:type] == 'link' or code[:oembed][:type] == 'link'
      html = self.to_linked_thumbnail(code, max_embed_width)

    # only show full embed if the width is less than max
    elsif !max_embed_width.nil? && !code[:oembed].empty? && code[:oembed].has_key?(:html)
      match = code[:oembed][:html].match(/width="(?<width>\d+)"/i) 
      if !match.nil?
        width = match[:width].to_i
        if width <= max_embed_width
          html = self.to_embed(code)
        end
      end
    end

    # otherwise show fancybox
    if html.nil?
      html = self.to_fancybox(code, max_embed_width)
    end

    return html
  end

  def to_embed
    EmbedlyService.to_embed(properties)
  end

  def self.to_embed(code)

    html = nil
    code = self.parse_raw(code)

    if code.has_key?(:oembed) and not code.has_key?(:error_code)
      if code[:oembed].has_key?(:html)
        html = code[:oembed][:html]
      elsif code[:oembed][:type] == 'photo'
        html = self.generate_img_html(code[:oembed])
      elsif code[:oembed][:type] == 'link' || code[:type] == 'link'
        html = self.generate_link_html(code[:oembed][:url], code[:oembed][:title])
      else
        html = self.generate_link_html(code[:url], code[:title])
      end
    end

    return html
  end

  def self.to_linked_thumbnail(code, maxwidth = nil)
    thumb = self.to_thumbnail(code, maxwidth)
    return self.generate_link_html(code[:url], code[:title], thumb)
  end

  def to_thumbnail(maxwidth = nil)
    EmbedlyService.to_thumbnail(properties, maxwidth)
  end

  def self.to_thumbnail(code, maxwidth = nil)

    html = nil
    img = nil
    code = self.parse_raw(code)

    if not code[:oembed].empty? and code[:oembed].has_key?(:thumbnail_url)
      img = {
        :url => code[:oembed][:thumbnail_url],
        :height => code[:oembed][:thumbnail_height],
        :width => code[:oembed][:thumbnail_width],
      }
    elsif !code[:images].empty?
      small = nil

      if maxwidth.nil?
        code[:images].each do |image|
          if img.nil? or (image[:width].to_i > img[:width].to_i)
            img = image
          end
        end
      else
        code[:images].each do |image|
          if image[:width].to_i < maxwidth && (img.nil? || image[:width].to_i > img[:width].to_i)
            img = image
          end
          if small.nil? or (image[:width].to_i < small[:width].to_i)
            small = image
          end
        end
        img = small if img.nil?
      end
    end 

    if not img.nil?
      if not maxwidth.nil? and img[:width].to_i > maxwidth
        img[:height] = img[:height].to_i * maxwidth / img[:width].to_i
        img[:width] = maxwidth
      end
      opt = { description: code[:description], title: code[:title] }
      opt.merge!(img)
      html = self.generate_img_html(opt)
    end

    return html
  end

  def to_fancybox(thumb_maxwdith = nil)
    EmbedlyService.to_thumbnail(properties, thumb_maxwidth)
  end

  def self.to_fancybox(code, thumb_maxwidth = nil)
    # http://fancybox.net/

    #<a id="inline" href="#data">thumbnail</a>
    #<div style="display:none"><div id="data">embed</div></div>

    #<a id="single_image" href="image_big.jpg"><img src="image_small.jpg" alt=""/></a>

    html = nil
    code = self.parse_raw(code)

    if code.has_key?(:oembed)

      r = 1000 + rand(9000)

      html = ''
      js = "
        <script type='text/javascript'> 
          //<![CDATA[
            $(document).ready(function() {
              $(\"a#single_image-#{r}\").fancybox({'scrolling': 'no'});
              $(\"a#inline-#{r}\").fancybox({'scrolling': 'no'});
            });
          //]]>
        </script>
      "

      thumbnail = self.to_thumbnail(code, thumb_maxwidth)

      if not thumbnail.nil?
        if code[:oembed][:type] == 'photo'
          html << js
          html << "<a id=\"single_image-#{r}\" href=\""
          html << code[:oembed][:url]
          html << '">'
          html << thumbnail
          html << '</a>'
        else
          html << js
          html << "<a id=\"inline-#{r}\" href=\"#data-#{r}\">"
          html << thumbnail
          html << '</a>'
          html << "<div style=\"display:none\"><div id=\"data-#{r}\">"
          html << self.to_embed(code)
          html << '</div></div>'
        end
      end
    end

    return html
  end

  protected

  def clear_state
    @error_code = 200
    @error = nil
    @properties = nil
  end

  def self.generate_img_html(opts)
    html = '<img'
    html << " src=\"#{opts[:url]}\"" if opts.has_key?(:url)
    html << " height=\"#{opts[:height]}\"" if opts.has_key?(:height)
    html << " width=\"#{opts[:width]}\"" if opts.has_key?(:width)
    html << " title=\"#{opts[:title]}\"" if opts.has_key?(:title)
    html << " alt=\"#{opts[:description]}\"" if opts.has_key?(:description)
    html << ' />'
    return html
  end

  def self.generate_thumbnail_html(opts)
    html = '<img'
    html << " src=\"#{opts[:thumbnail_url]}\"" if opts.has_key?(:thumbnail_url)
    html << " height=\"#{opts[:thumbnail_height]}\"" if opts.has_key?(:thumbnail_height)
    html << " width=\"#{opts[:thumbnail_width]}\"" if opts.has_key?(:thumbnail_width)
    html << " title=\"#{opts[:title]}\"" if opts.has_key?(:title)
    html << " alt=\"#{opts[:description]}\"" if opts.has_key?(:description)
    html << ' />'
    return html
  end

  def self.generate_link_html(url, title, link_body = nil)
    html = ''
    link_body = title if link_body.nil?
    if not url.nil? and not title.nil?
      html << '<a'
      html << " href=\"#{url}\""
      html << " title=\"#{title}\""
      html << '>'
      html << link_body
      html << '</a>'
    end
    return html
  end

end
