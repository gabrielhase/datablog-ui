class ChoroplethMap

  constructor: ({
    @id
    @mapMediatorService # TODO: is it possible to setup the angular $injector for models?
  }) ->
    @dataPointsWithMissingRegion = []
    @regionsWithMissingDataPoints = []


  getTemplate: ->
    choroplethMapConfig.template


  sanitizeVisualizationData: ->
    sanitizedData = @_getSnippetModel().data('data').map (dataEntry) ->
      sanitizedEntry = {}
      for key, value of dataEntry
        sanitizedKey = livingmapsWords.camelCase(key).replace('%', 'Percent')
        sanitizedValue = value
        sanitizedEntry[sanitizedKey] = sanitizedValue
      sanitizedEntry
    @_getSnippetModel().data
      data: sanitizedData


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
