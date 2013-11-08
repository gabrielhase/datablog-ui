class ChoroplethMap

  constructor: ({
    @id
    @mapMediatorService # TODO: is it possible to setup the angular $injector for models?
  }) ->
    @dataPointsWithMissingRegion = []
    @regionsWithMissingDataPoints = []
    @usedDataValues = []


  resetDataAggregations: ->
    @dataPointsWithMissingRegion = []
    @regionsWithMissingDataPoints = []
    @usedDataValues = []


  getTemplate: ->
    choroplethMapConfig.template


  # ngGrid uses the keys of the json as javascript objects (through angulars $parse)
  # thus we need to make them valid first
  getDataSanitizedForNgGrid: ->
    keyMapping = {}
    sanitizedData = @_getSnippetModel().data('data').map (dataEntry) ->
      sanitizedEntry = {}
      for key, value of dataEntry
        sanitizedKey = livingmapsWords.camelCase(key).replace('%', 'Percent')
        sanitizedValue = value
        sanitizedEntry[sanitizedKey] = sanitizedValue
        keyMapping[key] = sanitizedKey
      sanitizedEntry
    return { sanitizedData, keyMapping }


  # goes through all geojson properties on the map and separates the
  # properties into such that can be used for mapping data to it and such
  # that can not be used for mapping data to it.
  # NOTE: at the moment we don't check for distinctiveness of the values
  getPropertiesForMapping: ->
    propertiesForMapping = []
    propertiesWithMissingEntries = []
    lastPropertySet = undefined
    @_getSnippetModel().data('map')?.features?.map (feature) =>

      # make sure old missing properties are skipped
      currentPropertySet = {}
      for key, value of feature.properties
        currentPropertySet[key] = value if propertiesWithMissingEntries.indexOf(key) == -1

      # see if new missing properties arose
      if lastPropertySet
        newlyMissingProperties = @_findMissingProperties(currentPropertySet, lastPropertySet)
        for newlyMissingProperty in newlyMissingProperties
          propertiesWithMissingEntries.push(newlyMissingProperty)
          for propertySet in propertiesForMapping
            delete propertySet[newlyMissingProperty]

      propertiesForMapping.push(currentPropertySet)
      lastPropertySet = currentPropertySet

    { propertiesForMapping, propertiesWithMissingEntries }


  # goes through all csv columns on the data set and gets only those
  # columns that can be mapped to the current mapping property on the map
  getDataPropertiesForMapping: ->
    data = @_getSnippetModel().data('data')
    map = @_getSnippetModel().data('map')
    mappingPropertyOnMap = @_getSnippetModel().data('mappingPropertyOnMap')
    colMatchCount = {}

    for row in data
      rowAppliedToMap = false
      map?.features?.forEach (feature) ->
        return if rowAppliedToMap # only track application to the map once
        mappingValueOnMap = feature?.properties[mappingPropertyOnMap]
        for key, value of row
          if value == mappingValueOnMap
            colMatchCount[key] ||= 0
            colMatchCount[key] += 1
            rowAppliedToMap = true

    dataColumnsForMapping = []
    for key, value of colMatchCount
      if (value / map?.features.length) >= choroplethMapConfig.dataMappingThreshold
        dataColumnsForMapping.push(key)

    return dataColumnsForMapping


  # deduces if the selected value property stands for numerical or ordinal data
  # if >50% of values are numerical decides for numerical otherwise ordinal
  getValueType: ->
    data = @_getSnippetModel().data('data')
    valueProperty = @_getSnippetModel().data('valueProperty')
    return undefined unless data && valueProperty

    numericalRows = 0
    categoricalRows = 0
    for row in data
      valTypeToDetermine = row[valueProperty]
      if @_determineValueType(valTypeToDetermine) == 'numerical'
        numericalRows += 1
      else
        categoricalRows += 1

    if numericalRows > categoricalRows
      'numerical'
    else
      'categorical'


  getCategoryValues: ->
    data = @_getSnippetModel().data('data')
    valueProperty = @_getSnippetModel().data('valueProperty')
    return undefined unless data && valueProperty

    _.uniq(data.map (row) -> row[valueProperty])


  # render a loading bar only if the map changes or if we render a predefined map
  # everyhing else should be quick enough not to require a loading bar
  shouldRenderLoadingBar: (property) ->
    prefilledMapNames = choroplethMapConfig.prefilledMaps.map (map) -> map.name
    if @_getSnippetModel().data('map')
      switch property
        when 'colorScheme' then return false
        else
          return true
    else if prefilledMapNames.indexOf(@_getSnippetModel().identifier) != -1
      true
    else
      false


    ## PRIVATE FUNCITONS ##


  _determineValueType: (val) ->
    tryNumeric = +val

    if _.isNaN(tryNumeric)
      'categorical'
    else
      'numerical'


  # finds the difference in keys between literal current and literal last
  _findMissingProperties: (currentPropertySet, lastPropertySet) ->
    missingValues = []

    currentPropertySetKeys = for key, value of currentPropertySet
      key
    lastPropertySetKeys = for key, value of lastPropertySet
      key
    if currentPropertySetKeys.length != lastPropertySet.length
      for existedBefore in lastPropertySetKeys
        if currentPropertySetKeys.indexOf(existedBefore) == -1
          missingValues.push(existedBefore)

    missingValues


  _getSnippetModel: ->
    @mapMediatorService.getSnippetModel(@id)
