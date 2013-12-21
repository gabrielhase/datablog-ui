angular.module('ldEditor').controller 'WebMapFormController',
class WebMapFormController

  constructor: (@$scope, @ngProgress, @$http, @dialogService) ->
    @$scope.center = @$scope.snippet.model.data('center')
    @$scope.availableZoomLevels = [1..16]
    @$scope.kickstartPins = $.proxy(@kickstartPins, this)

    @watchCenter()


  kickstartPins: (data, error) ->
    if error.message
      alert(error.message)
    else
      @ngProgress.start()
      promise = @$http.post('http://geojsonlint.com/validate', data)
      promise.error (error) =>
        alert('Could not validate your json with geojsonlint.com. Do you have internet connection?')
        @ngProgress.complete()
      promise.success (response) =>
        if response.status == 'ok'
          @dialogService.openMapKickstartModal(data)
        else
          alert('This is not a geojson file. Sorry currently we only have support for geojson.')
        @ngProgress.complete()


  watchCenter: ($event) ->
    @$scope.$watch 'center.lat', (newVal, oldVal) =>
      if newVal
        oldSnippetModelData = @$scope.snippet.model.data('center')
        @$scope.snippet.model.data
          center:
            zoom: oldSnippetModelData.zoom
            lng: oldSnippetModelData.lng
            lat: newVal

    @$scope.$watch 'center.lng', (newVal, oldVal) =>
      if newVal
        oldSnippetModelData = @$scope.snippet.model.data('center')
        @$scope.snippet.model.data
          center:
            zoom: oldSnippetModelData.zoom
            lng: newVal
            lat: oldSnippetModelData.lat

    @$scope.$watch 'center.zoom', (newVal, oldVal) =>
      oldSnippetModelData = @$scope.snippet.model.data('center')
      @$scope.snippet.model.data
        center:
          zoom: newVal
          lng: oldSnippetModelData.lng
          lat: oldSnippetModelData.lat



    # @$scope.sidebarBecameVisible.add =>
    #   $timeout =>
    #     $compile(
    #       """
    #       <slider floor="100" ceiling="1000" step="50" precision="2" ng-model="center.zoomLevel"></slider>
    #       """
    #     )(@$scope, (slider, childScope) ->
    #       $('.sliderPlaceholder').html(slider)
    #     )
