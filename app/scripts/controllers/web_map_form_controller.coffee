angular.module('ldEditor').controller 'WebMapFormController',
class WebMapFormController

  constructor: (@$scope, @ngProgress, @$http, @dialogService, @mapMediatorService) ->
    @$scope.snippet = @mapMediatorService.getSnippetModel(@$scope.snippet.model.id)
    @$scope.uiModel = @mapMediatorService.getUIModel(@$scope.snippet.id)

    # NOTE: since the angular leaflet directive references the literals we need
    # to make sure to update all references so we need to work with deep copies
    @$scope.center = {}
    $.extend(true, @$scope.center, @$scope.snippet.data('center'))
    @$scope.markers = []
    $.extend(true, @$scope.markers, @$scope.snippet.data('markers'))
    @$scope.availableZoomLevels = [1..16]
    @$scope.newMarker = {}
    @$scope.tileLayer = @$scope.snippet.data('tiles').name

    @$scope.addMarker = $.proxy(@addMarker, this)
    @$scope.deleteMarker = $.proxy(@deleteMarker, this)
    @$scope.highlightMarker = $.proxy(@highlightMarker, this)
    @$scope.unHighlightMarker = $.proxy(@unHighlightMarker, this)
    @$scope.kickstartMarkers = $.proxy(@kickstartMarkers, this)
    @$scope.openFreeformEditor = $.proxy(@openFreeformEditor, this)
    @$scope.selectIcon = $.proxy(@selectIcon, this)

    @watchCenter()
    @watchMarkers()
    @watchTileLayer()


  # ########################
  # Marker Handling
  # ########################


  getHoverMarkerStyle: (currentIcon) ->
    if currentIcon?
      L.AwesomeMarkers.icon
        icon: currentIcon.options.icon
        prefix: currentIcon.options.prefix
        markerColor: 'green'


  resetHoverMarkerStyle: (currentIcon) ->
    if currentIcon?
      L.AwesomeMarkers.icon
        icon: currentIcon.options.icon
        prefix: currentIcon.options.prefix
        markerColor: 'cadetblue'


  highlightMarker: (index) ->
    @$scope.markers[index].icon = @getHoverMarkerStyle(@$scope.markers[index].icon)


  unHighlightMarker: (index) ->
    @$scope.markers[index].icon = @resetHoverMarkerStyle(@$scope.markers[index].icon)


  addMarker: ->
    if !@validateMarkers([@$scope.newMarker])
      alert('Please fill out the required fields')
    else
      newValidMarker = {}
      $.extend(true, newValidMarker, @$scope.newMarker)
      newValidMarker.uuid = livingmapsUid.guid()
      @$scope.markers.unshift(newValidMarker)
      @$scope.newMarker = {}


  deleteMarker: (index) ->
    @$scope.markers.splice(index, 1)


  selectIcon: (marker, icon) ->
    marker.icon = L.AwesomeMarkers.icon
      icon: icon
      markerColor: marker.icon.options.markerColor
      prefix: marker.icon.options.prefix


  # ########################
  # Geojson Kickstart
  # ########################

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
          @dialogService.openMapKickstartModal(data, @$scope.uiModel).result.then (result) =>
            if result.action == 'kickstart'
              @$scope.markers = result.markers
        else
          alert('This is not a geojson file. Sorry currently we only have support for geojson.')
        @ngProgress.complete()


  # ########################
  # Freeform Editor
  # ########################

  openFreeformEditor: ->
    @dialogService.openMapEditModal(@$scope.snippet, @$scope.uiModel)


  # ########################
  # Deep Copy Watchers
  # ########################

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


  watchTileLayer: ->
    @$scope.$watch 'tileLayer', (newVal, oldVal) =>
      @$scope.snippet.data
        tiles: @$scope.uiModel.getAvailableTileLayers()[newVal]


    # @$scope.sidebarBecameVisible.add =>
    #   $timeout =>
    #     $compile(
    #       """
    #       <slider floor="100" ceiling="1000" step="50" precision="2" ng-model="center.zoomLevel"></slider>
    #       """
    #     )(@$scope, (slider, childScope) ->
    #       $('.sliderPlaceholder').html(slider)
    #     )
