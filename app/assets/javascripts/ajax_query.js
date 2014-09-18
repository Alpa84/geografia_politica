
$(function(){
  /* Your javascripts goes here... */


  $(function() {

    $(document).on("submit",'.form-inline',function () {
      console.log($(this.action));
      $.ajax({
        url: this.action,
        type: 'POST',
        data: {raiting:{score:$(this).find('#raiting_score').val()}},
        dataType: 'script',

      });
      return false;
    });
  });

});