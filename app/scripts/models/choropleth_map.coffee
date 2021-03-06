class ChoroplethMap

  constructor: (@id) ->
    @mapMediatorService = angularHelpers.inject('mapMediatorService')
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
        sanitizedKey = livingmapsWords.camelCase(key).replace('%', 'Percent').replace('_', '')
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
    for row, idx in data
      rowKeysApplied = []
      map?.features?.forEach (feature) ->
        mappingValueOnMap = feature?.properties[mappingPropertyOnMap]
        for key, value of row
          continue if rowKeysApplied.indexOf(key) != -1
          if value == mappingValueOnMap
            colMatchCount[key] ||= 0
            colMatchCount[key] += 1
            rowKeysApplied.push(key)

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


  merge: (snippetModel) ->
    @_getSnippetModel().data
      mapId: snippetModel.data('mapId')
      map: snippetModel.data('map')
      lastPositioned: snippetModel.data('lastPositioned')
      projection: snippetModel.data('projection')
      data: snippetModel.data('data')
      mappingPropertyOnMap: snippetModel.data('mappingPropertyOnMap')
      mappingPropertyOnData: snippetModel.data('mappingPropertyOnData')
      valueProperty: snippetModel.data('valueProperty')
      colorSteps: snippetModel.data('colorSteps')
      colorScheme: snippetModel.data('colorScheme')


  calculateDifference: (otherVersion) ->
    versionDifferences = []
    versionDifferences.push
      sectionTitle: 'Map'
      properties: []
    versionDifferences[0].properties.push(@_calculateMapDifference(otherVersion))
    versionDifferences[0].properties.push(@_calculatePropertyDifference('projection', otherVersion))

    versionDifferences.push
      sectionTitle: 'Mapping'
      properties: []
    versionDifferences[1].properties.push(@_calculateMappingDifference(otherVersion))

    versionDifferences.push
      sectionTitle: 'Data'
      properties: []
    versionDifferences[2].properties = @_calculateDataSetDifference(otherVersion)

    versionDifferences.push
      sectionTitle: 'Visualization'
      properties: []
    versionDifferences[3].properties.push(@_calculatePropertyDifference('valueProperty', otherVersion))
    versionDifferences[3].properties.push(@_calculatePropertyDifference('colorScheme', otherVersion))
    versionDifferences[3].properties.push(@_calculatePropertyDifference('colorSteps', otherVersion))

    versionDifferences


  # render a loading bar only if the map changes or if we render a predefined map
  # everyhing else should be quick enough not to require a loading bar
  shouldRenderLoadingBar: (property) ->
    prefilledMapNames = choroplethMapConfig.prefilledMaps.map (map) -> map.name
    if @_getSnippetModel().data('map')
      switch property
        when 'colorScheme' then return false
        when 'hideLegend' then return false
        else
          return true
    else if prefilledMapNames.indexOf(@_getSnippetModel().identifier) != -1
      true
    else
      false


    ## PRIVATE FUNCITONS ##


  _determineValueType: (val) ->
    if $.isNumeric(val)
      'numerical'
    else
      'categorical'


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


  # ########################
  # DIFFERENCE CALCULATIONS
  # ########################

  _calculateMapDifference: (otherVersionSnippetModel) ->
    currentMap = @_getSnippetModel().data('map')
    otherMap = otherVersionSnippetModel.data('map')
    # only diff the regions
    currentRegions = currentMap?.features.map (feature) -> feature.geometry
    otherRegions = otherMap?.features.map (feature) -> feature.geometry
    mapDiffEntry =
      label: 'regions'
      key: 'map'
    if !@_deepEquals(currentRegions, otherRegions)
      mapDiffEntry.difference =
        type: 'blobChange'

    return mapDiffEntry


  _calculateMappingDifference: (otherVersionSnippetModel) ->
    currentValue = @_getSnippetModel().data('mappingPropertyOnMap')
    otherValue = otherVersionSnippetModel.data('mappingPropertyOnMap')
    propertyDiffEntry =
      label: 'mapping'
      key: 'mappingPropertyOnMap'
    propertyDiffEntry.difference = @_getDifferenceType(currentValue, otherValue)
    unless propertyDiffEntry.difference
      propertyDiffEntry.info = "on property #{currentValue}"
    propertyDiffEntry


  # generic calculation for change properties
  _calculatePropertyDifference: (property, otherVersionSnippetModel) ->
    currentValue = @_getSnippetModel().data(property)
    otherValue = otherVersionSnippetModel.data(property)
    propertyDiffEntry =
      label: livingmapsWords.wordize(property)
      key: property
    propertyDiffEntry.difference = @_getDifferenceType(currentValue, otherValue)
    unless propertyDiffEntry.difference
      propertyDiffEntry.info = "(#{currentValue})"
    propertyDiffEntry


  _calculateDataSetDifference: (otherVersionSnippetModel) ->
    currentData = @_getSnippetModel().data('data')
    otherData = otherVersionSnippetModel.data('data')

    differences = []
    additions = livingmapsDiff.differenceObjects(currentData, otherData)
    deletions = livingmapsDiff.differenceObjects(otherData, currentData)

    for addition in additions
      differences.push
        label: ''
        key: 'data'
        difference:
          type: 'add'
          content: _.values(addition).join(', ')
          unformattedContent: addition
    for deletion in deletions
      differences.push
        label: ''
        key: 'data'
        difference:
          type: 'delete'
          content: _.values(deletion).join(', ')
          unformattedContent: deletion

    return differences


  _getDifferenceType: (currentValue, otherValue) ->
    if !currentValue
      type: 'delete'
      content: otherValue
    else if !otherValue
      type: 'add'
      content: currentValue
    else if currentValue != otherValue
      type: 'change'
      previous: otherValue
      after: currentValue
    else
      undefined


  # very primitive implementation that does NOT work when contents come
  # in a different order, e.g. {a: 1, b: 2} != {b: 2, a: 1}
  # a better solution is here: http://stackoverflow.com/questions/1068834/object-comparison-in-javascript
  _deepEquals: (o1, o2) ->
    JSON.stringify(o1) == JSON.stringify(o2)
