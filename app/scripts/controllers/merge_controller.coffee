angular.module('ldEditor').controller 'MergeController',
class MergeController

  constructor: (@$scope, @mapMediatorService) ->
    @$scope.revertChange = (property) => @revertChange(property)
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


  isColorStepsWithOrdinalData: (property) ->
    property.key == 'quantizeSteps' && @$scope.valueType == 'categorical'


  # NOTE: we need to fire the change event manually since the latestVersionSnippet
  # is note in the snippetTree. This is kind of a hack and should be made better when
  # the engine allows multiple documents.
  _propagateSnippetChange: (changedProperty) ->
    doc.document.snippetTree.snippetDataChanged.fire(@$scope.latestSnippetVersion, [changedProperty])
