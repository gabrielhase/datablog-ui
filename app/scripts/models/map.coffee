class Map

  template = """
    <div ng-controller="MapController">
      <leaflet center="center" geojson="geojson">
      </leaflet>
    </div>
  """

  constructor: ({
  }) ->
    # nothing here yet


  # CLASS INTERFACE

  wasInserted: (snippetModel, scope) ->
    scope.center =  # my home
        lat: 47.388778
        lng: 8.541971
        zoom: 12

    scope.$watch('snippetModel.data("dataIdentifier")', (newVal) =>
      @populateData(snippetModel, scope)
    )
    scope.$watch('snippetModel.data("popupContentProperty")', (newVal) =>
      @populateData(snippetModel, scope)
    )

    @setupGeojsonListeners(scope)


  getTemplate: ->
    template


  # IMPLEMENTATION DETAILS

  populateData: (snippetModel, scope) ->
    newData = snippetModel.data('geojson')
    if newData
      scope.geojson =
        data: newData
        popupContentProperty: snippetModel.data('popupContentProperty')


  setupGeojsonListeners: (scope)->
  # scope.$on "leafletDirectiveMap.geojsonClick", (ev, featureSelected, leafletEvent) ->
  #   console.log(featureSelected)


