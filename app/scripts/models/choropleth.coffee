class ChoroplethMap

  template = """
    <div ng-controller="ChoroplethController">
      <choropleth data="data" map="map" last-positioned="lastPositioned">
      </choropleth>
    </div>
  """

  prefilledMaps = [
    {
      name: 'livingmaps.unemploymentChoropleth'
      map: 'usCounties'
      data: 'usUnemployment'
    }
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
    else if ChoroplethMap.getPrefilledMapNames.indexOf(snippetModel.identifier) != -1
      true
    else
      false


  populateData: (snippetModel, scope, ngProgress) ->
    for trackedProperty in ['map', 'data', 'lastPositioned']
      newVal = snippetModel.data(trackedProperty)
      if newVal
        if ngProgress.status() == 0 && @shouldRenderLoadingBar(snippetModel)
          ngProgress.start()
          ngProgress.set(10)
        scope[trackedProperty] = newVal


  @getPrefilledMaps: ->
    prefilledMaps


  @getPrefilledMapNames: ->
    prefilledMaps.map (map) -> map.name
