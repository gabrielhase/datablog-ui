angular.module('ldEditor').factory 'mapInsertService', ($rootScope, $compile) ->

  # Private Scope
  mapScopes = {}


  # Service

  isMapSnippet: (snippetModel) ->
    console.log snippetModel
    $template = snippetModel.template.$template
    $template.data('type') == 'angular-directive'


  insertMap: (snippetModel) ->
    $template = snippetModel.template.$template
    $directiveRoot = $template.find('*[data-placeholder="directive"]')
    $directiveRoot.html('')
    template = '<leaflet center="center" height="220px"></leaflet>'
    mapScope = $rootScope.$new()
    mapScopes[snippetModel] = mapScope
    $compile(template)(mapScope, (map, childScope) ->
      childScope.center =
        lat: 46.362093
        lng: 9.036255
        zoom: 10
      $directiveRoot.append(map)
      #$('.-js-editor-root').append(map)
    )


  removeMap: (snippetModel) ->
    scope = mapScopes[snippetModel]
    scope.$destroy()
    mapScopes[snippetModel] = undefined

