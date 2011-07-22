// Return a helper with preserved width of cells
var fixTableRowHelper = function(e, ui) {
  ui.children().each(function() {
    $(this).width($(this).width());
  });
  return ui;
};
var lastUpdatedRow = null;
var is_ascending = true;

function update_sort(event, ui){
  lastUpdatedRow = $(ui.item);
  var current_index = $(ui.item).find('td span.text').html();
  var next_index = $(ui.item).next().find('td span.text').html();
  var prev_index = $(ui.item).prev().find('td span.text').html();
  var data = { current: current_index, next: next_index, prev: prev_index };

  $.post('/admin/issues/update_order', data, function(data) {
    lastUpdatedRow.children().effect('highlight');
    $("table.issues tbody td:nth-child(4) span").each(function(index, element){
      if(is_ascending)
      {
        $(this).html(index);
      }else{
        var rows = $("table.issues tbody tr").length;
        $(this).html(rows - index - 1);
      }
    });
    $("table.issues tbody td:nth-child(4) span").each(function(index, element){
      if(is_ascending)
      {
        $(this).html(index);
      }else{
        var rows = $("table.issues tbody tr").length;
        $(this).html(rows - index - 1);
      }
    });
    $("table.issues").trigger("update");
  });
}

$(document).ready(function(){
  $("table.issues tbody").sortable({
    axis: "y",
    cancel: ".ui-state-disabled",
    containment: "table.issues tbody",
    cursor: "move",
    disabled: false,
    handle: ".handle",
    helper: fixTableRowHelper,
    items: "tr:not(.ui-state-disabled)",
    update: update_sort
  });
  $("table.issues tbody .handle").disableSelection();
});