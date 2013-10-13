class ChoroplethMap

  template = """
    <div ng-controller="ChoroplethController">
      <choropleth data="data" map="map" last-positioned="lastPositioned" projection="projection">
      </choropleth>
    </div>
  """

  prefilledMaps = [
    {
      name: 'livingmaps.unemploymentChoropleth'
      map: 'usCounties'
      data: 'usUnemployment'
      projection: 'albersUsa'
    }
  ]

  availableProjections = [
    name: 'USA (only US maps)'
    value: 'albersUsa'
  ,
    name: 'Mercator'
    value: 'mercator'
  ,
    name: 'Orthographical'
    value: 'orthographic'
  ,
    name: 'Plate carrée'
    value: 'equirectangular'
  ]

  constructor: ({

  }) ->
    # nothing here yet


  # CLASS INTERFACE


  wasInserted: (snippetModel, scope, ngProgress) ->
    snippetModel.data('lastPositioned', (new Date()).toJSON())
    scope.$watch('snippetModel.data("lastChangeTime")', (newVal) =>
      @populateData(snippetModel, scope, ngProgress)
    )


  getTemplate: ->
    template


  # IMPLEMENTATION DETAILS


  shouldRenderLoadingBar: (snippetModel) ->
    if snippetModel.data('map')
      true
    else if ChoroplethMap.getPrefilledMapNames().indexOf(snippetModel.identifier) != -1
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


  @getPrefilledMaps: ->
    prefilledMaps


  @getPrefilledMapNames: ->
    prefilledMaps.map (map) -> map.name


  @getProjections: ->
    availableProjections
