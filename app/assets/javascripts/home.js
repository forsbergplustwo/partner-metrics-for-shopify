// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var ready;
ready = function() {

  $(function () {
    $('[data-toggle="tooltip"]').tooltip()
  })

};

$(document).ready(ready);
$(document).on('page:load', ready);
