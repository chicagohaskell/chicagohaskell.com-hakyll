$('.post').sidenotes();

var sidenotize = function() {
  var width = $(window).width();
  if (width < 992) {
    $('.post').sidenotes('hide');
  } else {
    $('.post').sidenotes('show');
  }
};

sidenotize();
$(window).resize(sidenotize);
