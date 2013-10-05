class ChoroplethMap

  template = """
    <div ng-controller="ChoroplethController">
      <choropleth>
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


  populateData: ->
    # nothing here yet

