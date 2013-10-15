angular.module('ldEditor').service 'angularTemplateService', ($rootScope, $compile) ->

  # Service

  templateInstances: {}

  isAngularTemplate: (snippetModel) ->
    $template = snippetModel.template.$template
    typeof $template.attr('data-template') != "undefined"


  insertAngularTemplate: (snippetModel) ->
    snippetView = doc.document.renderer.snippetViews[snippetModel.id]
    for node in snippetView.$html.find('*[data-is]')
      switch $(node).data('is')
        when 'leaflet-map'
          @loadTemplate($(node), $.proxy(@insertTemplateInstance, this, snippetModel, $(node), new Map))
        when 'd3-choropleth'
          @loadTemplate($(node), $.proxy(@insertTemplateInstance, this, snippetModel, $(node), new ChoroplethMap))
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


  insertTemplateInstance: (snippetModel, $directiveRoot, instance) ->
    instanceScope = $rootScope.$new()
    $compile(instance.getTemplate())(instanceScope, (instanceHtml, childScope) =>
      childScope.snippetModel = snippetModel
      childScope.templateInstance = instance
      $directiveRoot.html(instanceHtml)
      @templateInstances[snippetModel.id] =
        instance: instance
        scope: instanceScope
    )
    $rootScope.$$phase || instanceScope.$digest() # digest immediately to get maps loading


  removeAngularTemplate: (snippetModel) ->
    scope = @templateInstances[snippetModel.id].scope
    scope.$destroy()
    @templateInstances[snippetModel.id] = undefined
