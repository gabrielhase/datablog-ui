angular.module('ldEditor').controller 'ChoroplethFormController',
class ChoroplethFormController

  constructor: (@$scope, @$http, @ngProgress, @dataService, @mapMediatorService, @dialogService) ->
    @choroplethInstance = @mapMediatorService.getUIModel(@$scope.snippet.model.id)
    @$scope.choroplethInstance = @choroplethInstance

    @$scope.setMap = (data, error) => @setMap(data, error)
    @$scope.setData = (data, error) => @setData(data, error)
    @$scope.openDataModal = (highlighedRows) => @openDataModal(highlighedRows)

    @$scope.projections = choroplethMapConfig.availableProjections
    @setupProperty('projection')
    @setupPredefinedMaps()

    if @$scope.snippet.model.data('map')
      @initMapPropertySelection()

    if @$scope.snippet.model.data('data')
      @initDataPropertySelection()

    @initMaxQuantizeSteps(@$scope.snippet.model.data('colorScheme'))


  openDataModal: (highlighedRows) ->
    modalInstance = @dialogService.openDataModal(highlighedRows, @$scope.snippet.model.id, @$scope.mappingPropertyOnData)
    modalInstance.result.then (data) ->
      console.log "closed modal"


  # generic property setup:
  # - init value to value of the same name on snippet model
  # - watch for changes and set to snippet model data when changed
  setupProperty: (property, customChangeBehavior) ->
    @$scope[property] = @$scope.snippet.model.data(property)
    @$scope.$watch(property, (newVal, oldVal) =>
      dataToSet = {}
      dataToSet[property] = newVal
      @$scope.snippet.model.data(dataToSet)
      customChangeBehavior(newVal) if customChangeBehavior
    )


  setupPredefinedMaps: ->
    @$scope.predefinedMaps = choroplethMapConfig.availableMaps
    @$scope.mapName = @$scope.snippet.model.data('mapName')
    @$scope.$watch 'mapName', (newVal, oldVal) =>
      if newVal && newVal != oldVal
        @ngProgress.start()
        @dataService.get(newVal.map).then (data) =>
          @ngProgress.complete()
          @$scope.snippet.model.data
            map: data
            mapName: newVal
            projection: newVal.projection

          @$scope.projection = newVal.projection
          @initMapPropertySelection()
          if newVal.data
            @dataService.get(newVal.data).then (data) =>
              dataValues = d3.csv.parse(data)
              @$scope.snippet.model.data
                data: dataValues
                mappingPropertyOnMap: newVal.mappingPropertyOnMap
                mappingPropertyOnData: newVal.mappingPropertyOnData
                valueProperty: newVal.valueProperty
              @$scope.mappingPropertyOnMap = newVal.mappingPropertyOnMap
              @$scope.mappingPropertyOnData = newVal.mappingPropertyOnData
              @$scope.valueProperty = newVal.valueProperty
              @initDataPropertySelection(dataValues)


  initMapPropertySelection: ->
    @setupProperty('mappingPropertyOnMap', $.proxy(@initDataMappingProperties, this))
    { propertiesForMapping, propertiesWithMissingEntries } = @choroplethInstance.getPropertiesForMapping(@$scope.snippet.model)
    if propertiesForMapping && propertiesForMapping.length > 0
      @$scope.availableMapProperties = []
      # NOTE: getPropertiesForMapping ensures that the properties are present in
      # all features so it's safe just to take the first
      for key, value of propertiesForMapping[0]
        @$scope.availableMapProperties.push
          label: "#{key} (e.g. #{value})"
          value: key


  initMaxQuantizeSteps: (colorScheme) ->
    matchingColorScheme = colorBrewerConfig.colorSchemes.filter (cScheme) ->
      cScheme.cssClass == colorScheme
    if matchingColorScheme.length > 0
      steps = matchingColorScheme[0].steps
    else
      steps = 9 # TODO: parameterize the magic number in a config

    @$scope.maxQuantizeSteps = steps
    @$scope.availableQuantizeSteps = [3..steps]

    # adjust selected quantize steps if necessary
    @$scope.quantizeSteps = steps if @$scope.quantizeSteps > steps


  initDataMappingProperties: ->
    data = @$scope.snippet.model.data('data')
    return unless data
    @$scope.availableDataMappingProperties = []
    properties = @choroplethInstance.getDataPropertiesForMapping()
    for key in properties
      @$scope.availableDataMappingProperties.push
        label: "#{key} (e.g. #{data[data.length-1][key]})"
        key: key


  initDataValueProperties: ->
    data = @$scope.snippet.model.data('data')
    @$scope.availableDataProperties = []
    if data && data.length > 0
      # NOTE: the last entry is more likely not to be a header row
      for key, value of data[data.length - 1]
        @$scope.availableDataProperties.push
          label: "#{key} (e.g. #{value})"
          key: key


  initDataPropertySelection: ->
    @setupProperty('mappingPropertyOnData')
    @setupProperty('valueProperty')
    @setupProperty('colorScheme', $.proxy(@initMaxQuantizeSteps, this))
    @setupProperty('quantizeSteps')
    @$scope.availableColorSchemes = colorBrewerConfig.colorSchemes
    @initDataValueProperties()
    @initDataMappingProperties()


  setData: (data, error) ->
    if error?.message
      alert(error.message)
    else
      @$scope.snippet.model.data
        data: data
      @initDataPropertySelection(data)


  setMap: (data, error) ->
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
          @$scope.snippet.model.data
            map: data
          @initMapPropertySelection()
        else
          alert('This is not a geojson file. Sorry currently we only have support for geojson.')
        @ngProgress.complete()
