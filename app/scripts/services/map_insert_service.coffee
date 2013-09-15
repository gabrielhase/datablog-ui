angular.module('ldEditor').factory 'mapInsertService', ($rootScope, $compile, dataService) ->

  # Private Scope
  mapScopes = {}


  # Service

  isMapSnippet: (snippetModel) ->
    $template = snippetModel.template.$template
    $template.data('type') == 'angular-directive'


  insertMap: (snippetModel) ->
    snippetView = doc.document.renderer.snippets[snippetModel.id]
    $directiveRoot = snippetView.$html.find('*[data-placeholder="leaflet-directive"]')
    template = '<div ng-controller="MapController"><leaflet center="center" geojson="geojson"></leaflet></div>'
    mapScope = $rootScope.$new()
    mapScopes[snippetModel.id] = mapScope
    $compile(template)(mapScope, (map, childScope) =>
      childScope.center =  # my home
        lat: 47.388778
        lng: 8.541971
        zoom: 12

      childScope.snippetModel = snippetModel
      childScope.$watch('snippetModel.data("dataIdentifier")', (newVal) =>
        @populateData(snippetModel, childScope)
      )
      childScope.$watch('snippetModel.data("popupContentProperty")', (newVal) =>
        @populateData(snippetModel, childScope)
      )

      @setupGeojsonListeners(childScope)

      $directiveRoot.html(map)
    )


  populateData: (snippetModel, scope) ->
    newData = snippetModel.data('geojson')
    if newData
      scope.geojson =
        data: newData
        popupContentProperty: snippetModel.data('popupContentProperty')



  removeMap: (snippetModel) ->
    scope = mapScopes[snippetModel.id]
    scope.$destroy()
    mapScopes[snippetModel.id] = undefined


  setupGeojsonListeners: (scope)->
    # scope.$on "leafletDirectiveMap.geojsonClick", (ev, featureSelected, leafletEvent) ->
    #   console.log(featureSelected)


