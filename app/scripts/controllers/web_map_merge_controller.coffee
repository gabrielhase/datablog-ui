angular.module('ldEditor').controller 'WebMapMergeController',
class WebMapMergeController

  constructor: (@$scope, @mapMediatorService, @leafletEvents) ->
    @$scope.revertChange = $.proxy(@revertChange, this)
    @$scope.revertAdd = $.proxy(@revertAdd, this)
    @$scope.revertDelete = $.proxy(@revertDelete, this)
    @$scope.highlightMarker = $.proxy(@highlightMarker, this)
    @$scope.unHighlightMarker = $.proxy(@unHighlightMarker, this)
    @setupMarkerEvents()
    @$scope.$watch 'versionDifference', (newVal, oldVal) =>
      if newVal
        @initMarkerColors()


  initMarkerColors: ->
    @$scope.resetHistoryMarkerProperties()
    for section in @$scope.versionDifference
      if section.sectionTitle == 'Markers'
        for property in section.properties
          {latestMarker, historyMarker} = @_getMarkersByUuid(property.uuid)
          if property.difference.type == 'change'
            latestMarker.icon.options.markerColor = 'orange'
            historyMarker.icon.options.markerColor = 'orange'
          else if property.difference.type == 'add'
            latestMarker.icon.options.markerColor = 'green'
          else if property.difference.type == 'delete'
            historyMarker.icon.options.markerColor = 'red'


  setupMarkerEvents: ->
    @$scope.events =
      markers:
        enable: @leafletEvents.getAvailableMarkerEvents()
    @$scope.$on 'leafletDirectiveMarker.mouseover', (e, args) =>
      @highlightMarker
        index: +args.markerName
    @$scope.$on 'leafletDirectiveMarker.mouseout', (e, args) =>
      @unHighlightMarker
        index: +args.markerName


  highlightMarker: (lookup) ->
    if lookup.property?
      {latestMarker, historyMarker} = @_getMarkersByUuid(lookup.property.uuid)
    else if lookup.index?
      {latestMarker, historyMarker} = @_getMarkersByIndex(lookup.index)
    else
      log.error "Don't know how to retrieve marker with lookup #{lookup}"

    if latestMarker?
      latestMarker.icon.options.spin = true
    if historyMarker?
      historyMarker.icon.options.spin = true


  unHighlightMarker: (lookup) ->
    if lookup.property?
      {latestMarker, historyMarker} = @_getMarkersByUuid(lookup.property.uuid)
    else if lookup.index?
      {latestMarker, historyMarker} = @_getMarkersByIndex(lookup.index)
    else
      log.error "Don't know how to retrieve marker with lookup #{lookup}"

    if latestMarker?
      latestMarker.icon.options.spin = false
    if historyMarker?
      historyMarker.icon.options.spin = false


  revertChange: (property) ->
    newData = {}
    newData[property.key] = @$scope.historyVersionSnippet.data(property.key)
    @$scope.latestSnippetVersion.data(newData)
    @_propagateSnippetChange(property.key)
    property.difference = undefined
    property.info = "(#{newData[property.key]})"
    @$scope.modalState.isMerging = true
    # reset this changes color coding
    {latestMarker, historyMarker} = @_getMarkersByUuid(property.uuid)
    @$scope.resetMarker(latestMarker)
    @$scope.resetMarker(historyMarker)


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
    # reset this changes color coding
    {latestMarker, historyMarker} = @_getMarkersByUuid(property.uuid)
    @$scope.resetMarker(latestMarker)
    @$scope.resetMarker(historyMarker)


  revertDelete: (property) ->
    if property.key == 'markers'
      markers = @$scope.latestSnippetVersion.data('markers')
      markers.push(property.difference.unformattedContent)
    else
      log.error "Don't know how to perform operation revertDelete on #{property.key}"

    @_propagateSnippetChange(property.key)
    property.difference = undefined
    @$scope.modalState.isMerging = true
    # reset this changes color coding
    {latestMarker, historyMarker} = @_getMarkersByUuid(property.uuid)
    @$scope.resetMarker(latestMarker)
    @$scope.resetMarker(historyMarker)


  _getMarkersByUuid: (uuid) ->
    latestMarker = _.find @$scope.latestSnippetVersion.data('markers'), (marker) =>
      marker.uuid == uuid
    historyMarker = _.find @$scope.historyVersionSnippet.data('markers'), (marker) =>
      marker.uuid == uuid

    {latestMarker, historyMarker}


  _getMarkersByIndex: (index) ->
    latestMarker = @$scope.latestSnippetVersion.data('markers')[index]
    historyMarker = @$scope.historyVersionSnippet.data('markers')[index]

    {latestMarker, historyMarker}


  # NOTE: we need to fire the change event manually since the latestVersionSnippet
  # is not in the snippetTree. This is kind of a hack and should be made better when
  # the engine allows multiple documents.
  _propagateSnippetChange: (changedProperty) ->
    doc.document.snippetTree.snippetDataChanged.fire(@$scope.latestSnippetVersion, [changedProperty])
