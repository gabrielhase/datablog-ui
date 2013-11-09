angular.module('ldEditor').controller 'ImageEmbedController',
class ImageEmbedController

  constructor: (@$scope, @uiStateService) ->
    @image = @uiStateService.state.imagePopover.image
    @imagePathAttr = @uiStateService.state.imagePopover.imagePath

    @$scope.embedImage = (url) => @embedImage(url)


  embedImage: (url) ->
    @image.model.set(@imagePathAttr, url)
    @closePopover()


  closePopover: ->
    @uiStateService.set('imagePopover', false)
