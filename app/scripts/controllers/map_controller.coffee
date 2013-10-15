angular.module('ldEditor').controller 'MapController',
class MapController

  constructor: (@$scope) ->
    @snippetModel = @$scope.snippetModel
    @$scope.center =   # my home
      lat: 47.388778
      lng: 8.541971
      zoom: 12

    @setupListeners()


  setupListeners: ->
    @$scope.$watch('snippetModel.data("dataIdentifier")', (newVal) =>
      @populateData()
    )
    @$scope.$watch('snippetModel.data("popupContentProperty")', (newVal) =>
      @populateData()
    )


  populateData: ->
    newData = @snippetModel.data('geojson')
    if newData
      @$scope.geojson =
        data: newData
        popupContentProperty: @snippetModel.data('popupContentProperty')


  # setupGeojsonListeners: (scope)->
  # scope.$on "leafletDirectiveMap.geojsonClick", (ev, featureSelected, leafletEvent) ->
  #   console.log(featureSelected)
