$(document).ready(function() {
  var formElements = {
    'title' : $('[name*="title"]'),
    'header' : $('#post-header'),
    'content' : $('[name*="content"]'),
    'preview_link' : $('#post-preview')
  };

  var previewElements = {
    'title' : $('#preview-title'),
    'content' : $('#preview-content'),
    'container' : $('#preview-content-container'),
    'hide_preview' : $('#preview-hide')
  };

  // Note: these draft elements are either global or on posts/new
  var draftElements = {
    'count' : $('#drafts-count'),
    'drafts_link' : $('#drafts-link'),
    'save_button' : $('#save-draft')
  };

  var initGlobalDraftElements = function() {
    initDraftCount();
    bindDraftLink();
  }

  var initDraftCount = function() {
    $.ajax({
      url: '/draft_count',
      type: 'get',
      success: function(data) {
        draftElements.count.html(data['draft_count']);

        if (data['draft_count'] > 0 && !isOneOfDraftsPages()) {
          draftElements.drafts_link.addClass('bold');
        }
      }
    })
  }

  var initForm = function() {
    if (isNewPostPage()) {
      formElements.form = $('form.new_post');
    } else if (isNewDraftPage()) {
      formElements.form = $('form.new_draft');
    } else if (isEditPostPage()) {
      formElements.form = $('form.edit_post');
    } else if (isEditDraftPage()) {
      formElements.form = $('form.edit_draft');
    }
  }

  var initPreview = function() {
    previewElements.container.hide();
  }

  var bindElements = function() {
    bindSaveDraft();
    bindShowPreview();
    bindHidePreview();
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

  var bindDraftLink = function() {
    draftElements.drafts_link.on('click', function() {
      if ($(this).hasClass('bold')) {
        $(this).removeClass('bold');
      }
      window.location = '/drafts'
    });
  }

  // This is only for saving a draft when on posts/new
  var bindSaveDraft = function() {
    draftElements.save_button.on('click', function() {
      formElements.form.attr('action', '/drafts');
      formElements.title.attr('name', "draft[title]");
      formElements.content.attr('name', "draft[content]");
      formElements.form.submit();
    });
  }

  var showPreview = function(data) {
    // This is necessary after redirect to /drafts
    if (formElements.form == undefined) {
      initForm();
    }

    formElements.form.hide();
    formElements.header.hide();
    previewElements.title.show();
    previewElements.container.slideDown();
    previewElements.title.html(data['preview_title']);
    previewElements.content.html(data['preview_content']);
  }

  var hidePreview = function() {
    previewElements.title.hide();
    previewElements.container.hide();
    formElements.header.show();
    formElements.form.slideDown();
  }

  var userLoggedIn = function() {
    return document.cookie.includes('signed_in=1');
  }

  var isNewPostPage = function() {
    return $('body').hasClass('posts new');
  }

  var isNewDraftPage = function() {
    return $('body').hasClass('drafts new');
  }

  var isEditPostPage = function() {
    return $('body').hasClass('posts edit');
  }

  var isDraftsIndexPage = function() {
    return $('body').hasClass('drafts index');
  }

  var isEditDraftPage = function() {
    return $('body').hasClass('drafts edit');
  }

  var isPreviewablePage = function() {
    return isNewPostPage() || isNewDraftPage() || isEditPostPage() || isEditDraftPage();
  }

  var isOneOfDraftsPages = function() {
    return isDraftsIndexPage() || isNewDraftPage() || isEditDraftPage();
  }

  var isBlogPage = function() {
    return $('body').hasClass('posts') || $('body').hasClass('drafts')
  }

  var run = function() {
    if (userLoggedIn() && isBlogPage()) {
      initGlobalDraftElements();

      if (isPreviewablePage()) {
        initForm();
        initPreview();
        bindElements();
      }
    }
  }

  run();
});
