angular.module('ldEditor').controller 'WebMapFormController',
class WebMapFormController

  constructor: (@$scope, @ngProgress, @$http, @dialogService, @mapMediatorService) ->
    @$scope.snippet = @mapMediatorService.getSnippetModel(@$scope.snippet.model.id)

    @$scope.center = {}
    $.extend(true, @$scope.center, @$scope.snippet.data('center'))
    @$scope.markers = []
    $.extend(true, @$scope.markers, @$scope.snippet.data('markers'))
    @$scope.availableZoomLevels = [1..16]

    @$scope.kickstartMarkers = $.proxy(@kickstartMarkers, this)
    @$scope.deleteMarker = $.proxy(@deleteMarker, this)
    @$scope.highlightMarker = $.proxy(@highlightMarker, this)
    @$scope.unHighlightMarker = $.proxy(@unHighlightMarker, this)

    @initMarkerStyles()
    @watchCenter()
    @watchMarkers()


  initMarkerStyles: ->
    @hoverMarker = L.AwesomeMarkers.icon
      icon: 'fa-cogs'
      markerColor: 'green'
      prefix: 'fa'


  highlightMarker: (index) ->
    @$scope.markers[index].icon = @hoverMarker


  unHighlightMarker: (index) ->
    @$scope.markers[index].icon = undefined


  deleteMarker: (index) ->
    @$scope.markers.splice(index, 1)


  kickstartMarkers: (data, error) ->
    if error.message
      alert(error.message)
    else
      @ngProgress.start()
      promise = @$http.post('http://geojsonlint.com/validate', data)
      promise.error (error) =>
        alert('Could not validate your json with geojsonlint.com. Do you have internet connection?')
        @ngProgress.complete()
      promise.success (response) =>
        if response.status == 'ok'
          @dialogService.openMapKickstartModal(data).result.then (result) =>
            if result.action == 'kickstart'
              @$scope.markers = result.markers
        else
          alert('This is not a geojson file. Sorry currently we only have support for geojson.')
        @ngProgress.complete()


  watchCenter: () ->
    @$scope.$watch 'center.lat', (newVal, oldVal) =>
      if newVal && $.isNumeric(newVal)
        oldSnippetModelData = @$scope.snippet.data('center')
        @$scope.snippet.data
          center:
            zoom: oldSnippetModelData.zoom
            lng: oldSnippetModelData.lng
            lat: newVal

    @$scope.$watch 'center.lng', (newVal, oldVal) =>
      if newVal && $.isNumeric(newVal)
        oldSnippetModelData = @$scope.snippet.data('center')
        @$scope.snippet.data
          center:
            zoom: oldSnippetModelData.zoom
            lng: newVal
            lat: oldSnippetModelData.lat

    @$scope.$watch 'center.zoom', (newVal, oldVal) =>
      if newVal && $.isNumeric(newVal)
        oldSnippetModelData = @$scope.snippet.data('center')
        @$scope.snippet.data
          center:
            zoom: newVal
            lng: oldSnippetModelData.lng
            lat: oldSnippetModelData.lat


  # NOTE: the angular leaflet directive does not allow input of invalid
  # markers thus we need to work with deep copies
  watchMarkers: ->
    @$scope.$watch 'markers', (newVal, oldVal) =>
      if newVal && @validateMarkers(newVal)
        newMarkers = []
        $.extend(true, newMarkers, newVal)
        @$scope.snippet.data
          markers: newMarkers
    , true


  validateMarkers: (markers) ->
    _.every markers, (marker) ->
      $.isNumeric(marker.lat) && $.isNumeric(marker.lng)


    # @$scope.sidebarBecameVisible.add =>
    #   $timeout =>
    #     $compile(
    #       """
    #       <slider floor="100" ceiling="1000" step="50" precision="2" ng-model="center.zoomLevel"></slider>
    #       """
    #     )(@$scope, (slider, childScope) ->
    #       $('.sliderPlaceholder').html(slider)
    #     )
