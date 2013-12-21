angular.module('ldEditor').controller 'WebMapController',
class WebMapController

  constructor: (@$scope, @mapMediatorService) ->
    @snippetModel = @mapMediatorService.getSnippetModel(@$scope.mapId)
    @snippetModel.data
      lastPositioned: (new Date()).getTime()

    @setupSnippetChangeListener()
    @initScope()


  initScope: ->
    @$scope.snippetModel = @mapMediatorService.getSnippetModel(@$scope.mapId)
    @$scope.center =   # my home
      lat: 47.388778
      lng: 8.541971
      zoom: 12


  setupSnippetChangeListener: ->
    doc.snippetDataChanged (snippet, changedProperties) =>
      if snippet.id == @snippetModel.id
        @changeMapAttrsData(changedProperties)


  changeMapAttrsData: (changedProperties) ->
    for trackedProperty in webMapConfig.trackedProperties
      if changedProperties.indexOf(trackedProperty) != -1
        newVal = @snippetModel.data(trackedProperty)
        if typeof(newVal) != 'undefined'
          @$scope[trackedProperty] = newVal


    newData = @snippetModel.data('geojson')
    if newData
      @$scope.geojson =
        data: newData
        popupContentProperty: @snippetModel.data('popupContentProperty')


  # setupGeojsonListeners: (scope)->
  # scope.$on "leafletDirectiveMap.geojsonClick", (ev, featureSelected, leafletEvent) ->
  #   console.log(featureSelected)
