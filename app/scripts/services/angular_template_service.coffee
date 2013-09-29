angular.module('ldEditor').service 'angularTemplateService', ($rootScope, $compile) ->

  # Private Scope
  LEAFLET_MAP_TEMPLATE = """
    <div ng-controller="MapController">
      <leaflet center="center" geojson="geojson">
      </leaflet>
    </div>
  """

  # Service

  mapScopes: {}

  isAngularTemplate: (snippetModel) ->
    $template = snippetModel.template.$template
    typeof $template.attr('data-template') != "undefined"


  insertAngularTemplate: (snippetModel) ->
    snippetView = doc.document.renderer.snippets[snippetModel.id]
    for node in snippetView.$html.find('*[data-is]')
      switch $(node).data('is')
        when 'leaflet-map'
          @loadTemplate($(node), $.proxy(@insertMap, this, snippetModel, $(node)))
        else
          alert("unknown template value #{$(node).data('is')}")


  loadTemplate: ($node, callback) ->
    dependency = $node.data('dependency')
    resourceList = $node.data('dependency-resources')
    if dependency
      yepnope [{
        test: window.hasOwnProperty(dependency)
        nope: resourceList.split(';')
        complete: =>
          callback()
      }]
    else
      callback()


  insertMap: (snippetModel, $directiveRoot) ->
    template = LEAFLET_MAP_TEMPLATE
    mapScope = $rootScope.$new()
    @mapScopes[snippetModel.id] = mapScope
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


  removeAngularTemplate: (snippetModel) ->
    @removeMap(snippetModel)


  removeMap: (snippetModel) ->
    scope = @mapScopes[snippetModel.id]
    scope.$destroy()
    @mapScopes[snippetModel.id] = undefined


  setupGeojsonListeners: (scope)->
    # scope.$on "leafletDirectiveMap.geojsonClick", (ev, featureSelected, leafletEvent) ->
    #   console.log(featureSelected)


