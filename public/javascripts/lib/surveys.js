//Surveys
function updateSelectedOptionID(){
  updateOptionID(this)
}

function updateOptionID(selector){
  var value = '';
  var $input = $(selector).find('input.selected_option_id')[0];
  var $selected_option = $(selector).find('.survey-option')[0];
  if($selected_option){ value = $($selected_option).data('option-id');}    
  $($input).val(value);
}

function receivingItem(event,ui){
  if($(this).find('.survey-option').length > 1){
    var current_id = ui.item.data('option-id');
    var $existing_item = $(this).find('.survey-option[data-option-id!='+current_id+']').first();
    $existing_item.hide();
    $(ui.sender).append($existing_item);
    $existing_item.show('fast');
    updateOptionID(ui.sender);
  }
}

jQuery(function ($) {
  $(document).ready(function() {
  
    //drag and drop of the votes
    if($('.selected-survey-options input.submit').attr('disabled') != true){
      $('.survey-options .sortable').sortable({ 
        connectWith: '.selected-survey-options .sortable',
        cursor: 'crosshair',
        placeholder: "survey-option-placeholder"
      });

      $('.selected-survey-options .sortable').sortable({ 
        connectWith: '.survey-options .sortable, .selected-survey-options .sortable',
        update: updateSelectedOptionID,
        receive: receivingItem,
        placeholder: "survey-option-placeholder"
      });
      
    }
    
    // expand contract of the options
    $('.survey-option .expand').click(function(){
      $(this).closest('.survey-option').find('.description').show();
      $(this).closest('.menu').hide();
      return false;
    });
    
    $('.survey-option .contract').click(function(){
      $(this).closest('.description').hide();
      $(this).closest('.survey-option').find('div.menu').show();
      return false;
    });
    
    // close colorbox on cancelation of confirmation
    $('a.cancel_vote').live('click', function(){
      $.colorbox.close();
      return false;
    })
    
    // submits the form with without AJAX when the vote has been confirmed.
    $('a.confirm_vote').live('click', function(){
      var $form = $('.selected-survey-options form');
      var $confirmed_input = $("<input>").attr("type", "hidden").attr("name", "survey_response_presenter[confirmed]").val("true");
      $form.removeAttr('data-remote');
      $form.append($confirmed_input);
      $form.submit();
      return false;
    })
    
    
  });
});
