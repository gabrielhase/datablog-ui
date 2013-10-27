angular.module('ldEditor').factory 'dialogService', ($dialog, $modal, uiStateService) ->

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


    dataModalOptions =
      template: htmlTemplates.dataModal
      controller: 'DataModalController'


    # Service
    # -------

    # angular ui bootstrap 0.4.0 dialog
    openImageGallery: (image, imagePathAttr) ->
      $dialog.dialog(imageGalleryDialogOptions).open().then (result) =>
        if result && result.action == 'add'
          image.model.set(imagePathAttr, result.image.original)


    # angular ui bootstrap 0.6.0 modal
    openDataModal: (highlightedRows) ->
      dataModalOptions.resolve =
        highlightedRows: ->
          highlightedRows
      $modal.open(dataModalOptions)
