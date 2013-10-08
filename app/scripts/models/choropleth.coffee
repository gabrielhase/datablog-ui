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


  wasInserted: (snippetModel, scope, ngProgress) ->
    snippetModel.data('lastPositioned', (new Date()).toJSON())
    scope.$watch('snippetModel.data("lastChangeTime")', (newVal) =>
      @populateData(snippetModel, scope, ngProgress)
    )


  getTemplate: ->
    template


  # IMPLEMENTATION DETAILS


  populateData: (snippetModel, scope, ngProgress) ->
    for trackedProperty in ['map', 'data', 'lastPositioned']
      newVal = snippetModel.data(trackedProperty)
      if newVal
        if ngProgress.status() == 0
          ngProgress.start()
          ngProgress.set(10)
        scope[trackedProperty] = newVal
