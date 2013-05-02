// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

function bind_promote_demote_click (element) {
  element = $(element);
  var modal = $('#myModal');
  element.on('click', function(){
    modal.modal();
    var self = $(this),
        parent = self.parent();
    $.get(self.attr('href'), function(html){
      window.location.hash = $(window).scrollTop();
      window.location.reload();
    });
    return false;
  });
}

$('td.promote-or-demote li a').each(function(){
  bind_promote_demote_click(this);
})

$('.comment-form').bind('ajax:send', function(){
  $(this).find('.submit').button('loading');
}).bind('ajax:complete', function(){
  var element = $(this), comment, link;
  element.find('.submit').button('reset');
  element.parents('.modal').modal('hide');
  comment = element.find('textarea').val();
  link = element.parents('td.comments').find('a.comment-link');
  if (comment.length > 0) {
    link.text('View');
  }else{
    link.text('Add');
  }
});

$(function(){
  var current_location = window.location.pathname.split('/')[1];
  $('#top-nav').find('a[href*='+current_location+']').parent().addClass('active');
  $('#top-nav ul.followups li').removeClass('active');

  try{
    var current_location = window.location.search.split("=")[1].split("&")[0];
    $('#districts').find('a[href*='+current_location+']').parent().addClass('active');
  }catch(e){}

  $(window).scrollTop(window.location.hash.split("#")[1]);

  var toggle_id = $('#toggle-id'),
      toggle_parent = toggle_id.parent(),
      ids = $('.id');
  toggle_id.click(function(){
    toggle_parent.toggleClass('active');
    ids.toggleClass('hide');
  });
});