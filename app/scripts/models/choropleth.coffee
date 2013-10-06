class ChoroplethMap

  template = """
    <div ng-controller="ChoroplethController">
      <choropleth data="data" map="map" last-positioned="lastPositioned">
      </choropleth>
    </div>
  """

  constructor: ({

  }) ->
    # nothing here yet


  # CLASS INTERFACE


  wasInserted: (snippetModel, scope) ->
    snippetModel.data('lastPositioned', (new Date()).toJSON())
    scope.$watch('snippetModel.data("lastChangeTime")', (newVal) =>
      @populateData(snippetModel, scope)
    )


  getTemplate: ->
    template


  # IMPLEMENTATION DETAILS


  populateData: (snippetModel, scope) ->
    for trackedProperty in ['map', 'data', 'lastPositioned']
      newVal = snippetModel.data(trackedProperty)
      if newVal
        scope[trackedProperty] = newVal
