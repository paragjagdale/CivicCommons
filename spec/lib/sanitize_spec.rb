require 'spec_helper'
require 'sanitize'

describe Sanitize do
  context "will remove HTML elements" do
    before(:all) do
      @html = '<b><a href="http://foo.com/">foo</a></b><img src="http://foo.com/bar.jpg">'
      @text = 'This is a sentance\' without HTML tags in it which is > not.'
    end

    it "when tags exist" do
      Sanitize.clean(@html).should == 'foo'
    end

    it "when tags do not exist" do
      Sanitize.clean(@text).should == CGI.escapeHTML(@text)
    end

  end

  it 'will remove <script> elements' do
    html = <<-CONTENT
<p style="height: 570px; position: relative;">
<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="940" height="580" id="player" style="position: absolute; top: 0pt; left: 0pt;">
<param name="wmode" value="opaque">
<param name="movie" value="http://mediasuite.multicastmedia.com/templates/16x9-4x3-combo.swf">
<param name="quality" value="high">
<param name="bgcolor" value="#F7F1CD">
<param name="allowFullScreen" value="true">
<param name="allowScriptAccess" value="always">
<param name="play" value="true">
<param name="flashvars" value="sToken=s7x4o6n2&amp;gfToken=&amp;serviceURL=http://mediasuite.multicastmedia.com/services/index.php&amp;doResize=false&amp;typePlayer=live">
<embed src="http://mediasuite.multicastmedia.com/templates/16x9-4x3-combo.swf" quality="high" bgcolor="#F7F1CD" allowfullscreen="true" allowscriptaccess="always" width="940" height="580" flashvars="sToken=s7x4o6n2&amp;gfToken=&amp;serviceURL=http://mediasuite.multicastmedia.com/services/index.php&amp;doResize=false&amp;typePlayer=live" name="player" align="middle" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" style="position: absolute; top: 0pt; left: 0pt;" wmode="opaque"></embed>
</object>
</p>
<script type="text/javascript">
function launchPlayer(){
window.open('ht'+'tp:/'+'/'+'mediasuite'+'.multica'+'stmedia.c'+'om/playerlive.php?s=s7x4o6n2&doResize=true','newwindow', 'height=580,width=910','toolbar=no,menubar=no,resizable=no,scrollbars=no,status=no,location=no');
}
</script>
<p>
<a href="javascript:launchPlayer()">View in separate window</a>
</p>
CONTENT
    Sanitize.clean(html, :remove_contents => ['script']).strip.should == 'View in separate window'
  end
end