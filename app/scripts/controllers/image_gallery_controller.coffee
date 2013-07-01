angular.module('ldEditor').controller 'ImageGalleryController',
class ImageGalleryController

  constructor: (@$scope, @dialog, @imageService) ->
    @loadData()
    @$scope.close = (result) => @close(result)
    @$scope.addImage = (image) => @addImage(image)
    @$scope.setPage = (pageNo) => @setPage(pageNo)
    @$scope.search = => @search()


  close: (result) ->
    @dialog.close(
      action: 'close'
    )


  loadData: (opts = {}) ->
    { info, images } = @imageService.get(opts)
    @$scope.images = images
    @$scope.info = info


  setPage: (pageNo) ->
    @loadData
      pageNo: pageNo
      query: @$scope.lastQuery # always go with last query (pressed search)


  search: () ->
    # reset page to page 1
    @$scope.lastQuery = @$scope.query
    @loadData
      query: @$scope.query


  addImage: (image) ->
    @dialog.close(
      action: 'add'
      image: image
    )
