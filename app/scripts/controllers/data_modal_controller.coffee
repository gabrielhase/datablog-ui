angular.module('ldEditor').controller 'DataModalController',
class DataModalController

  constructor: (@$scope, @$modalInstance, @mapMediatorService, @highlightedRows, @mapId, @mappedColumn) ->
    @$scope.close = (event) => @close(event)
    @$scope.isHighlighted = (property) =>
      @highlightedRows.indexOf(property) != -1

    @choroplethMapInstance = @mapMediatorService.getUIModel(@mapId)
    @$scope.visualizedData = @choroplethMapInstance.getDataSanitizedForNgGrid()
    @$scope.gridOptions =
      data: 'visualizedData'
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


  close: (event) ->
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost

