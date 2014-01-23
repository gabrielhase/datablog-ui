angular.module('ldEditor').controller 'WebMapMergeController',
class WebMapMergeController

  constructor: (@$scope, @mapMediatorService) ->
    @$scope.revertChange = $.proxy(@revertChange, this)
    @$scope.revertAdd = $.proxy(@revertAdd, this)
    @$scope.revertDelete = $.proxy(@revertDelete, this)


  revertChange: (property) ->
    newData = {}
    newData[property.key] = @$scope.historyVersionSnippet.data(property.key)
    @$scope.latestSnippetVersion.data(newData)
    @_propagateSnippetChange(property.key)
    property.difference = undefined
    property.info = "(#{newData[property.key]})"
    @$scope.modalState.isMerging = true


  revertAdd: (property) ->
    if property.key == 'markers'
      markers = @$scope.latestSnippetVersion.data('markers')
      idx = -1
      for entry, entryIdx in markers
        if _.isEqual(entry, property.difference.unformattedContent)
          idx = entryIdx
      markers.splice(idx, 1) if idx != -1
    else
      log.error "Don't know how to perform operation revertAdd on #{property.key}"

    @_propagateSnippetChange(property.key)
    property.difference = undefined
    @$scope.modalState.isMerging = true


  revertDelete: (property) ->
    if property.key == 'markers'
      markers = @$scope.latestSnippetVersion.data('markers')
      markers.push(property.difference.unformattedContent)
    else
      log.error "Don't know how to perform operation revertDelete on #{property.key}"

    @_propagateSnippetChange(property.key)
    property.difference = undefined
    @$scope.modalState.isMerging = true


  # NOTE: we need to fire the change event manually since the latestVersionSnippet
  # is not in the snippetTree. This is kind of a hack and should be made better when
  # the engine allows multiple documents.
  _propagateSnippetChange: (changedProperty) ->
    doc.document.snippetTree.snippetDataChanged.fire(@$scope.latestSnippetVersion, [changedProperty])
