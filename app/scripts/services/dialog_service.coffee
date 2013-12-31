angular.module('ldEditor').factory 'dialogService', ($modal, uiStateService) ->

    # Private
    # -------

    dataModalOptions =
      template: htmlTemplates.dataModal
      controller: 'DataModalController'
      windowClass: 'upfront-modal-full-width'

    historyModalOptions =
      template: htmlTemplates.historyModal
      controller: 'HistoryModalController'
      windowClass: 'upfront-modal-full-width'

    mapKickstartModalOptions =
      template: htmlTemplates.mapKickstartModal
      controller: 'MapKickstartModalController'
      windowClass: 'upfront-modal-full-width'

    mapEditModalOptions =
      template: htmlTemplates.mapEditModal
      controller: 'MapEditModalController'
      windowClass: 'upfront-modal-full-width'

    # Service
    # -------

    # angular ui bootstrap 0.6.0 modal
    openDataModal: (highlightedRows, mapId, mappedColumn) ->
      dataModalOptions.resolve =
        highlightedRows: ->
          highlightedRows
        mapId: ->
          mapId
        mappedColumn: ->
          mappedColumn
      $modal.open(dataModalOptions)


    openHistoryModal: (snippet) ->
      historyModalOptions.resolve =
        snippet: ->
          snippet.model
      $modal.open(historyModalOptions)


    openMapKickstartModal: (data) ->
      mapKickstartModalOptions.resolve =
        data: ->
          data
      $modal.open(mapKickstartModalOptions)


    openMapEditModal: (snippet) ->
      mapEditModalOptions.resolve =
        snippet: ->
          snippet.model
      $modal.open(mapEditModalOptions)
