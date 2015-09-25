$(document).ready(function() {
  var formElements = {
    'title' : $('[name="post[title]"]'),
    'header' : $('#post-header'),
    'content' : $('[name="post[content]"]'),
    'preview_link' : $('#post-preview')
  };

  var previewElements = {
    'title' : $('#preview-title'),
    'content' : $('#preview-content'),
    'container' : $('#preview-container'),
    'content_container' : $('preview-content-container'),
    'hide_preview' : $('#preview-hide')
  };

  var draftElements = {
    'count' : $('#drafts-count'),
    'save_button' : $('#save-draft')
  };

  var bindElements = function() {
    bindSaveDraft();
    bindShowPreview();
    bindHidePreview();
  }

  var initDraftCount = function() {
    $.ajax({
      url: '/draft_count',
      type: 'get',
      success: function(data) {
        draftElements.count.html(data['draft_count']);
      }
    })
  }

  var initForm = function() {
    if (isNewPostPage()) {
      formElements.form = $('#new_post');
    } else if (isEditPostPage()) {
      formElements.form = $('form.edit_post');
    }
  }

  var initPreview = function() {
    previewElements.container.hide();
  }

  var bindShowPreview = function() {
    formElements.preview_link.on('click', function() {
      $.ajax({
        url: 'preview',
        type: 'post',
        data: {
          title: formElements.title.val(),
          content: formElements.content.val()
        },
        success: function(data) {
          showPreview(data);
        }
      });
    });
  }

  var bindHidePreview = function() {
     previewElements.hide_preview.on('click', function() {
      hidePreview();
    });
  }

  var bindSaveDraft = function() {
    draftElements.save_button.on('click', function() {
      formElements.form.attr('action', '/drafts');
      formElements.title.attr('name', "draft[title]");
      formElements.content.attr('name', "draft[content]");
      formElements.form.submit();
    });
  }

  var showPreview = function(data) {
    formElements.form.hide();
    formElements.header.hide();
    previewElements.title.show();
    previewElements.container.slideDown();
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

  initDraftCount();

  if (shouldRunOnPage()) {
    initForm();
    initPreview();
    bindElements();
  }
});
