$(document).ready(function() {
  var formElements = {
    'title' : $('#post_title'),
    'header' : $('#post_header'),
    'content' : $('#post_content'),
    'preview_link' : $('#post_preview')
  };

  var previewElements = {
    'title' : $('#preview_title'),
    'content' : $('#preview_content'),
    'container' : $('#preview_container'),
    'hide_preview' : $('#preview_hide')
  };

  var bindElements = function() {
    if (isNewPostPage()) {
      formElements.form = $('#new_post');
    } else if (isEditPostPage()) {
      formElements.form = $('form.edit_post');
    }

    previewElements.hide_preview.on('click', function() {
      hidePreview();
    });

    formElements.preview_link.on('click', function() {
      $.ajax({
        url: 'preview',
        type: 'post',
        data: {
          title: formElements.title.val(),
          content: formElements.content.val()
        },
        success: function(data) {
          displayPreview(data);
        }
      });
    });
  }

  var displayPreview = function(data) {
    formElements.form.slideUp();
    formElements.header.hide();
    previewElements.container.show();
    previewElements.title.html(data['preview_title']);
    previewElements.content.html(data['preview_content']);
  }

  var hidePreview = function() {
    previewElements.container.hide();
    formElements.header.show();
    formElements.form.slideDown();
  }

  var isNewPostPage = function() {
    return $('body').hasClass('posts new');
  }

  var isEditPostPage = function() {
    return $('body').hasClass('posts edit');
  }

  var shouldRunOnPage = function() {
    return isNewPostPage() || isEditPostPage();
  }

  if (shouldRunOnPage()) {
    previewElements.container.hide();
    bindElements();
  }
});
