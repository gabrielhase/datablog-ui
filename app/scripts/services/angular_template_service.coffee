angular.module('ldEditor').service 'angularTemplateService', ($rootScope, $compile, mapMediatorService) ->

  yepnopeQueue = {}

  # Service

  isAngularTemplate: (snippetModel) ->
    $template = snippetModel.template.$template
    typeof $template.attr('data-template') != "undefined"


  insertAngularTemplate: (snippetModel) ->
    snippetView = doc.document.renderer.snippetViews[snippetModel.id]
    for node in snippetView.$html.find('*[data-is]')
      switch $(node).data('is')
        when 'leaflet-map'
          @loadTemplate($(node), $.proxy(@insertTemplateInstance, this,
            snippetModel, $(node), new Map
              id: snippetModel.id
              mapMediatorService: mapMediatorService
          ))
        when 'd3-choropleth'
          @loadTemplate($(node), $.proxy(@insertTemplateInstance, this,
            snippetModel, $(node), new ChoroplethMap
              id: snippetModel.id
              mapMediatorService: mapMediatorService
            ))
        else
          alert("unknown template value #{$(node).data('is')}")


  loadTemplate: ($node, callback) ->
    dependency = $node.data('dependency')
    resourceList = $node.data('dependency-resources')
    if dependency
      cb = yepnopeQueue[dependency]
      unless cb
        cb = $.Callbacks('once memory')
        yepnopeQueue[dependency] = cb
      cb.add(callback)

      yepnope [{
        test: window.hasOwnProperty(dependency)
        nope: resourceList.split(';')
        complete: =>
          yepnopeQueue[dependency].fire()
      }]
    else
      callback()


  insertTemplateInstance: (snippetModel, $directiveRoot, instance) ->
    instanceScope = $rootScope.$new()
    $compile(instance.getTemplate())(instanceScope, (instanceHtml, childScope) =>
      mapMediatorService.set(snippetModel.id, snippetModel, instance, childScope)
      childScope.mapId = snippetModel.id
      $directiveRoot.html(instanceHtml)
    )
    $rootScope.$$phase || instanceScope.$digest() # digest immediately to get maps loading


  removeAngularTemplate: (snippetModel) ->
    scope = mapMediatorService.getScope(snippetModel.id)
    scope.$destroy()
    mapMediatorService.reset(snippetModel.id)
