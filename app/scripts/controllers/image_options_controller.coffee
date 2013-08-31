angular.module('ldEditor').controller 'ImageOptionsController',
class ImageOptionsController

  constructor: (@$scope, @uiStateService, @dialogService, @docService) ->
    @$scope.clickImageGalleryBtn = => @clickImageGalleryBtn()
    @docService.imageClickCleanup.add($.proxy(@closePopover, @))


  clickImageGalleryBtn: ->
    # open the image gallery
    @dialogService.openImageGallery(@uiStateService.state.imagePopover.image, @uiStateService.state.imagePopover.imagePath)
    @closePopover()


  closePopover: ->
    # close the popover
    @uiStateService.set('imagePopover', false)
