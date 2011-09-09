// requires JQuery and TinyMCE (with the JQuery plugin)

function init_tiny_mce(JqueryListOfElements){
  $(JqueryListOfElements).tinymce({
    script_url : '/javascripts/vendor/tiny_mce/tiny_mce.js',
    mode : "textareas",
    //theme : "simple",
    theme : "advanced",
    // turned off autoresize because it doesn't seem to work very well
    //plugins : 'autoresize',
    width : '100%',
    theme_advanced_buttons1 : "bold,italic,underline,strikethrough,|,link,unlink,|,bullist,numlist,|,undo,redo,|,cut,copy,paste",
    theme_advanced_buttons2 : "",
    theme_advanced_buttons3 : "",
    theme_advanced_toolbar_location : "top",
    theme_advanced_toolbar_align : "left"
  });
}

function clear_contribution_tool_form() {
  $(':input','#contribution_new')
    .not(':button, :submit, :reset, :hidden')
    .val('')
    .removeAttr('checked')
    .removeAttr('selected');
  if(typeof $('#contribution_content').tinymce == 'function')
  {
    $('#contribution_content').tinymce().setContent('');
  }
  $("#contrib #error_explanation").remove();
}

function get_contribution_parent_id(container) {
    var contribution_id = container.attr('id');
    contribution_id = contribution_id.match(/respond-to-(\d+)/);
    if (contribution_id instanceof Array && contribution_id.length == 2) {
      return contribution_id[1];
    } else {
      return false;
    }
}

function show_contribution_tool(container, contribution_id, title) {
  $('#contribution_content').tinymce().remove();
  $('#contribution_parent_id').val(contribution_id);
  $('.contrib_tool_container .title').html(title + ':');
  if (null != container) {
    container.append($('#contrib'));
  } else {
    $('#contribution_tool_container').append($('#contrib'));
  }
  $('#contrib').removeClass('hide_contrib_tool');
  init_tiny_mce('#contribution_content');
  scroll_to_contribution_tool();
}

function hide_contribution_tool() {
  $('.contrib_tool_container .title').html('');
  $('#contrib').addClass('hide_contrib_tool');
}

function scroll_to_contribution_tool() {
  $('html, body').animate({
    scrollTop: $('#contrib').offset().top
  }, 500);
}

function scroll_to_element(element) {
  $('html, body').animate({
    scrollTop: element.offset().top
  }, 500);
}

function enable_post_to_conversation(element) {
  element.live('click', function(event) {
    event.preventDefault();
    clear_contribution_tool_form();
    var contribution_id = get_contribution_parent_id($(this));
    var title = $(this).attr('title');
    if (contribution_id) {
      show_contribution_tool($(this).parents('.respond-container'), contribution_id, title);
    } else {
      show_contribution_tool(null, null, title);
    }
    $('#contribution_content').tinymce().focus();
  });
}

function enable_cancel_contribution(element) {
  element.click(function(event) {
    event.preventDefault();
    hide_contribution_tool();
    scroll_to_element($(this).parents('.contribution-container'));
  });
}

function enable_add_link_toggle(link, url_field, content_field) {
  link.click(function(event) {
    event.preventDefault();
    url_field.toggle();
    if ('none' != url_field.css('display')) {
      url_field.focus();
    } else {
      content_field.tinymce().focus();
    }
  });
}

function enable_add_file_toggle(link, file_field, content_field) {
  link.click(function(event) {
    event.preventDefault();
    file_field.toggle();
    if ('none' != file_field.css('display')) {
      file_field.focus();
    } else {
      content_field.tinymce().focus();
    }
  });
}
