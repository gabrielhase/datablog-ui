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
    template = '<div ng-controller="MapController"><leaflet center="center" geojson="geojson"></leaflet><a ng-click="testClick()" class="upfront-control">testEvent</a></div>'
    mapScope = $rootScope.$new()
    mapScopes[snippetModel.id] = mapScope
    $compile(template)(mapScope, (map, childScope) ->
      childScope.center =  # my home
        lat: 47.388778
        lng: 8.541971
        zoom: 12
      childScope.geojson =
        data: dataService.get('spielplatz')
      $directiveRoot.html(map)
    )


  removeMap: (snippetModel) ->
    scope = mapScopes[snippetModel.id]
    scope.$destroy()
    mapScopes[snippetModel.id] = undefined

