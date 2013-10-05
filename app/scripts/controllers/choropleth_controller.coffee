angular.module('ldEditor').controller 'ChoroplethController',
class ChoroplethController

  constructor: (@$scope, @dataService) ->
    @$scope.map = @dataService.get('usCounties')
    # nothing here yet
