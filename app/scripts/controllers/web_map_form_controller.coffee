angular.module('ldEditor').controller 'WebMapFormController',
class WebMapFormController

  constructor: (@$scope) ->
    @$scope.center = @$scope.snippet.model.data('center')
    @$scope.availableZoomLevels = [1..16]

    @watchZoom()
    @$scope.setLng = $.proxy(@setLng, this)
    @$scope.setLat = $.proxy(@setLat, this)


  setLat: ($event) ->
    $el = $($event.currentTarget)
    oldSnippetModelData = @$scope.snippet.model.data('center')
    @$scope.snippet.model.data
      center:
        zoom: oldSnippetModelData.zoom
        lng: oldSnippetModelData.lng
        lat: +$el.val()


  setLng: ($event) ->
    $el = $($event.currentTarget)
    oldSnippetModelData = @$scope.snippet.model.data('center')
    @$scope.snippet.model.data
      center:
        zoom: oldSnippetModelData.zoom
        lng: +$el.val()
        lat: oldSnippetModelData.lat


  watchZoom: ->
    @$scope.$watch('center.zoom', (newVal, oldVal) =>
      oldSnippetModelData = @$scope.snippet.model.data('center')
      console.log oldSnippetModelData
      @$scope.snippet.model.data
        center:
          zoom: newVal
          lng: oldSnippetModelData.lng
          lat: oldSnippetModelData.lat
    )



    # @$scope.sidebarBecameVisible.add =>
    #   $timeout =>
    #     $compile(
    #       """
    #       <slider floor="100" ceiling="1000" step="50" precision="2" ng-model="center.zoomLevel"></slider>
    #       """
    #     )(@$scope, (slider, childScope) ->
    #       $('.sliderPlaceholder').html(slider)
    #     )
