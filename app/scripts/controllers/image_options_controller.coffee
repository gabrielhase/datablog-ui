angular.module('ldEditor').controller 'ImageOptionsController',
class ImageOptionsController

  constructor: (@$scope, @uiStateService, @dialogService, @livingdocsService) ->
    @$scope.clickImageGalleryBtn = => @clickImageGalleryBtn()
    @livingdocsService.imageClickCleanup.add($.proxy(@closePopover, @))


  clickImageGalleryBtn: ->
    # open the image gallery
    @dialogService.openImageGallery(@uiStateService.state.imagePopover.image, @uiStateService.state.imagePopover.imagePath)
    @closePopover()


  closePopover: ->
    # close the popover
    @uiStateService.set('imagePopover', false)
