$(document).ready(function() {
  var formElements = {
    'title' : $('#post_title'),
    'content' : $('#post_content'),
    'preview_link' : $('#post_preview')
  };

  var previewElements = {
    'title' : $('#preview_title'),
    'content' : $('#preview_content'),
    'container' : $('#preview_container')
  };

  formElements.preview_link.on('click', function() {
    $.ajax({
      url: 'preview',
      type: 'POST',
      data: {
        title: formElements.title.val(),
        content: formElements.content.val()
      },
      success: function(data) {
        previewElements.container.removeClass('hidden');
        previewElements.title.html(data['preview_title']);
        previewElements.content.html(data['preview_content']);
      }
    });
  });
});
