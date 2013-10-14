class ChoroplethMap

  # CLASS DEFINITION

  constructor: ({

  }) ->
    # nothing here yet


  # CLASS INTERFACE


  wasInserted: (snippetModel, scope, ngProgress) ->
    snippetModel.data
      lastPositioned: (new Date()).toJSON()
    doc.snippetDataChanged (snippet, changedProperties) =>
      if snippet.id == snippetModel.id
        @populateData(snippetModel, scope, ngProgress)


  getTemplate: ->
    choroplethMapConfig.template


  # IMPLEMENTATION DETAILS


  shouldRenderLoadingBar: (snippetModel) ->
    prefilledMapNames = choroplethMapConfig.prefilledMaps.map (map) -> map.name
    if snippetModel.data('map')
      true
    else if prefilledMapNames.indexOf(snippetModel.identifier) != -1
      true
    else
      false


  processValue: (property, value) ->
    switch property
      when 'projection'
        if value
          eval("d3.geo.#{value}()")
      else
        value


  populateData: (snippetModel, scope, ngProgress) ->
    for trackedProperty in ['map', 'data', 'lastPositioned', 'projection']
      newVal = @processValue(trackedProperty, snippetModel.data(trackedProperty))
      if newVal
        if ngProgress.status() == 0 && @shouldRenderLoadingBar(snippetModel)
          ngProgress.start()
          ngProgress.set(10)
        scope[trackedProperty] = newVal

