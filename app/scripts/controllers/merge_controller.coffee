angular.module('ldEditor').controller 'MergeController',
class MergeController

  constructor: (@$scope, @mapMediatorService) ->
    @$scope.revertChange = (property) => @revertChange(property)
    @$scope.revertAdd = (property) => @revertAdd(property)
    @$scope.revertDelete = (property) => @revertDelete(property)
    @$scope.isColorStepsWithOrdinalData = (property) => @isColorStepsWithOrdinalData(property)
    @modelInstance = @mapMediatorService.getUIModel(@$scope.latestSnippetVersion.id)
    @initValueType()
    @$scope.$watch "latestSnippetVersion.data('valueProperty')", (newVal) =>
      @initValueType()


  initValueType: ->
    @$scope.valueType = @modelInstance.getValueType()


  revertChange: (property) ->
    key = property.key
    newData = {}
    newData[property.key] = @$scope.historyVersionSnippet.data(property.key)
    @$scope.latestSnippetVersion.data(newData)
    @_propagateSnippetChange(key)
    property.difference = undefined
    property.info = "(#{newData[property.key]})" unless property.key == 'map'


  revertDelete: (property) ->
    # todo


  revertAdd: (property) ->
    if property.key == 'data'
      # NOTE: since keeping track of indexes in the array over several merges
      # would be a pain we look for the index on each action.
      data = @$scope.latestSnippetVersion.data('data')
      idx = data.indexOf(property.difference.unformattedData)
      data.splice(idx, 1)
    else
      log.error "Don't know how to perform operation revertAdd on #{property.key}"


  isColorStepsWithOrdinalData: (property) ->
    property.key == 'quantizeSteps' && @$scope.valueType == 'categorical'


  # NOTE: we need to fire the change event manually since the latestVersionSnippet
  # is note in the snippetTree. This is kind of a hack and should be made better when
  # the engine allows multiple documents.
  _propagateSnippetChange: (changedProperty) ->
    doc.document.snippetTree.snippetDataChanged.fire(@$scope.latestSnippetVersion, [changedProperty])
