angular.module('ldEditor').controller 'MergeController',
class MergeController

  constructor: (@$scope, @mapMediatorService) ->
    @$scope.revertChange = $.proxy(@revertChange, this)
    @$scope.revertAdd = $.proxy(@revertAdd, this)
    @$scope.revertDelete = $.proxy(@revertDelete, this)
    @$scope.isColorStepsWithOrdinalData = $.proxy(@isColorStepsWithOrdinalData, this)
    @modelInstance = @mapMediatorService.getUIModel(@$scope.latestSnippetVersion.id)
    @initValueType()
    @$scope.$watch "latestSnippetVersion.data('valueProperty')", (newVal) =>
      @initValueType()


  # TODO: there shouldn't be type checking here...
  initValueType: ->
    if @$scope.latestSnippetVersion.identifier == 'livingmaps.choropleth'
      @$scope.valueType = @modelInstance.getValueType()


  revertChange: (property) ->
    key = property.key
    newData = {}
    newData[property.key] = @$scope.historyVersionSnippet.data(property.key)
    @$scope.latestSnippetVersion.data(newData)
    @_propagateSnippetChange(key)
    property.difference = undefined
    property.info = "(#{newData[property.key]})" unless property.key == 'map'
    @$scope.modalState.isMerging = true


  revertDelete: (property) ->
    if property.key == 'data'
      # always add the data row to the end
      data = @$scope.latestSnippetVersion.data('data')
      data.push(property.difference.unformattedContent)
    else
      log.error "Don't know how to perform operation revertAdd on #{property.key}"

    @_propagateSnippetChange(property.key)
    property.difference = undefined
    @$scope.modalState.isMerging = true


  revertAdd: (property) ->
    if property.key == 'data'
      # NOTE: since keeping track of indexes in the array over several merges
      # would be a pain we look for the index on each action.
      data = @$scope.latestSnippetVersion.data('data')
      idx = -1
      for entry, entryIdx in data
        if _.isEqual(entry, property.difference.unformattedContent)
          idx = entryIdx
      data.splice(idx, 1) if idx != -1
    else
      log.error "Don't know how to perform operation revertAdd on #{property.key}"

    @_propagateSnippetChange(property.key)
    property.difference = undefined
    @$scope.modalState.isMerging = true


  isColorStepsWithOrdinalData: (property) ->
    property.key == 'colorSteps' && @$scope.valueType == 'categorical'


  # NOTE: we need to fire the change event manually since the latestVersionSnippet
  # is not in the snippetTree. This is kind of a hack and should be made better when
  # the engine allows multiple documents.
  _propagateSnippetChange: (changedProperty) ->
    doc.document.snippetTree.snippetDataChanged.fire(@$scope.latestSnippetVersion, [changedProperty])
