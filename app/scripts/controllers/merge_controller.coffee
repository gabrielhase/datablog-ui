angular.module('ldEditor').controller 'MergeController',
class MergeController

  constructor: (@$scope) ->
    @$scope.revertChange = (property) => @revertChange(property)


  revertChange: (property) ->
    key = property.key
    newData = {}
    newData[property.key] = @$scope.historyVersionSnippet.data(property.key)
    @$scope.latestSnippetVersion.data(newData)
    @_propagateSnippetChange(key)
    property.difference = undefined
    property.info = "(#{newData[property.key]})"


  # NOTE: we need to fire the change event manually since the latestVersionSnippet
  # is note in the snippetTree. This is kind of a hack and should be made better when
  # the engine allows multiple documents.
  _propagateSnippetChange: (changedProperty) ->
    doc.document.snippetTree.snippetDataChanged.fire(@$scope.latestSnippetVersion, [changedProperty])
