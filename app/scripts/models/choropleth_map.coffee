class ChoroplethMap

  # CLASS DEFINITION

  constructor: ({

  }) ->
    # nothing here yet


  getTemplate: ->
    choroplethMapConfig.template


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
