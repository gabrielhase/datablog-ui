angular.module('ldEditor').controller 'DataModalController',
class DataModalController

  constructor: (@$scope, @$modalInstance, @mapMediatorService, @highlightedRows, @mapId, @mappedColumn) ->
    @$scope.close = (event) => @close(event)
    @$scope.isHighlighted = (property) =>
      isHighlighted = false
      for row in @highlightedRows
        if row.key == property
          isHighlighted = true
      isHighlighted
    @$scope.updateEntity = (row) => @updateEntity(row)

    @choroplethMapInstance = @mapMediatorService.getUIModel(@mapId)
    @snippetModel = @mapMediatorService.getSnippetModel(@mapId)
    { sanitizedData, keyMapping } = @choroplethMapInstance.getDataSanitizedForNgGrid()
    @keyMapping = keyMapping
    @$scope.visualizedData = sanitizedData

    # set index for later referal when setting values (updateEntity)
    for entry, index in @$scope.visualizedData
      entry['ldDataIndex'] = index

    @changedRows = []
    @setupGrid()


  setupGrid: ->
    cellEditableTemplate = "<input ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ng-blur=\"updateEntity(row.entity)\"/>"
    colDefs = []
    for key, value of @$scope.visualizedData[0]
      if key != 'ldDataIndex'
        colDefs.push(
          field: key
          displayName: livingmapsWords.camelCase(key).replace('%', 'Percent')
          enableCellSelection: true
          editableCellTemplate: cellEditableTemplate
        )

    @$scope.gridOptions =
      data: 'visualizedData'

      multiSelect: false
      enableRowSelection: false,
      enableCellEditOnFocus: true,
      rowTemplate: """
        <div style="height: 100%"
             ng-class="{red: isHighlighted(row.getProperty(\'#{@mappedColumn}\'))}">
          <div ng-style="{ \'cursor\': row.cursor }"
                ng-repeat="col in renderedColumns" ng-class="col.colIndex()" class="ngCell ">
            <div class="ngVerticalBar" ng-style="{height: rowHeight}" ng-class="{ ngVerticalBarVisible: !$last }">
            </div>
            <div ng-cell>
            </div>
          </div>
        </div>"""
      columnDefs: colDefs


  close: (event) ->
    if @changedRows.length > 0
      data = []
      $.extend(true, data, @snippetModel.data('data'))
      for rowIdx in @changedRows
        newRow = {}
        for key, value of data[rowIdx]
          mappedKey = @keyMapping[key]
          newRow[key] = @$scope.visualizedData[rowIdx][mappedKey]
        data[rowIdx] = newRow

      @snippetModel.data
        data: data

    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost


  updateEntity: (row) ->
    @changedRows.push(row.ldDataIndex)
