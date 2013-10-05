class ChoroplethMap

  template = """
    <div ng-controller="ChoroplethController">
      <choropleth data="data" map="geojsonMap">
      </choropleth>
    </div>
  """

  constructor: ({

  }) ->
    # nothing here yet


  # CLASS INTERFACE


  wasInserted: (snippetModel, scope) ->
    scope.$watch('snippetModel.data("dataIdentifier")', (newVal) =>
      @populateData(snippetModel, scope)
    )


  getTemplate: ->
    template


  # IMPLEMENTATION DETAILS


  populateData: ->
    # nothing here yet

