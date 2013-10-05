angular.module('ldEditor').factory 'dialogService', ($dialog, uiStateService) ->

    # Private
    # -------

    imageGalleryDialogOptions =
      backdrop: true
      keyboard: true
      backdropClick: true
      template: htmlTemplates.imageGallery
      controller: 'ImageGalleryController'
      dialogClass: 'upfront-modal'
      backdropClass: 'upfront-modal-backdrop'


    # Service
    # -------

    openImageGallery: (image, imagePathAttr) ->
      $dialog.dialog(imageGalleryDialogOptions).open().then (result) =>
        if result && result.action == 'add'
          image.model.set(imagePathAttr, result.image.original)
