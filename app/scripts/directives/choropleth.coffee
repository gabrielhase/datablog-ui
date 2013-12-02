angular.module('ldEditor').directive 'choropleth', ($timeout, ngProgress, mapMediatorService) ->

  #    #############################################
  #      Render Entry Point
  #    #############################################

  renderVisualization = (scope) ->
    if scope.map
      path = deducePathProjection(scope.projection)
      if path
        renderMap(scope, path)

        map = scope.map
        data = scope.data
        valueProperty = scope.valueProperty
        mappingPropertyOnMap = scope.mappingPropertyOnMap
        mappingPropertyOnData = scope.mappingPropertyOnData

        bounds =  path.bounds(scope.map)
        resizeMap(scope.svg, bounds)

        if data
          colorSteps = scope.colorSteps
          allMappingPropertiesOnMap = deduceAllAvailableMappingOnMap(scope.map, scope.mappingPropertyOnMap)
          valFn = deduceValueFunction(scope, colorSteps, allMappingPropertiesOnMap)
          renderData(scope, valFn)
          renderLegend(scope, valFn)


  #    #############################################
  #      Map Rendering
  #    #############################################

  # remove all paths from the svg
  # this is needed since d3 identifies by array index which is overlapping
  # across maps
  removeExistingMap = (mapGroup) ->
    mapPaths = mapGroup.selectAll('path')
      .data([])
    mapPaths.exit().remove()


  renderMap = (scope, path) ->
    mapPaths = scope.mapGroup.selectAll('path')
      .data(scope.map.features)
    mapPaths.enter().append('path')
      .attr('d', path)


  # sets the viewBox attribute on the svg element to cover the whole map
  # dynamically adjusts the snippet height to the ratio to the viewBox
  resizeMap = (svg, bounds) ->
    svgHeight = bounds[1][1] - bounds[0][1]
    svgWidth = bounds[1][0] - bounds[0][0]
    svg.attr('viewBox', "#{bounds[0][0]} #{bounds[0][1]} #{svgWidth} #{svgHeight}")
    ratio = $(svg.node()).width() / svgWidth
    svg.attr('stroke-width', (1 / ratio) )
    svg.attr('height', ratio * svgHeight)


  deducePathProjection = (projection) ->
    if projection
      d3.geo.path().projection(eval("d3.geo.#{projection}()"))
    else
      undefined


  #    #############################################
  #      Data Visualization
  #    #############################################

  tooltipShow = (d, i) ->
    $(this).tooltip(
      title: "#{$(@).attr('data-region')}: #{$(@).attr('data-title')}"
      placement: 'auto'
      container: $(this).parents('.doc-section')
    ).attr('data-original-title',
            "#{$(@).attr('data-region')}: #{$(@).attr('data-title')}"
    ).tooltip('show')


  getMappingProperty = (property) ->
    if $.isNumeric(property)
      +property
    else
      property


  renderData = (scope, valFn) ->
    return if typeof scope.data != 'object'

    mapInstance = mapMediatorService.getUIModel(scope.mapId)
    mapInstance.resetDataAggregations()
    valueById = getDataMap(scope, mapInstance)

    usedDataPoints = []
    paths = scope.mapGroup.selectAll('path')
      .attr('data-title', (d) ->
        mapPropertyId = getMappingProperty(d.properties[scope.mappingPropertyOnMap])
        valueById.get(mapPropertyId)
      )
      .attr('data-region', (d) ->
        getMappingProperty(d.properties[scope.mappingPropertyOnMap])
      )
      .attr('class', (d) ->
        mapPropertyId = getMappingProperty(d.properties[scope.mappingPropertyOnMap])
        val = valueById.get(mapPropertyId)
        if val
          mapInstance.usedDataValues.push(val) if mapInstance.usedDataValues.indexOf(val) == -1
          usedDataPoints.push("#{mapPropertyId}") # NOTE: since valueById.keys() will return the keys as string in any case, we will push this as strings as well
        else
          mapInstance.regionsWithMissingDataPoints.push(mapPropertyId)
        valFn(val)
      )

    paths.on('mouseover', tooltipShow)

    for entry in valueById.entries()
      if usedDataPoints.indexOf(entry.key) == -1
        mapInstance.dataPointsWithMissingRegion.push(entry)


  # returns a map with the key as the mapped property and the value as the visualization value
  getDataMap = (scope, mapInstance) ->
    valueById = d3.map()
    for d in scope.data
      dataPropertyId = getMappingProperty(d[scope.mappingPropertyOnData])
      if mapInstance.getValueType() == 'categorical'
        val = d[scope.valueProperty]
      else
        val = +d[scope.valueProperty]
      valueById.set(dataPropertyId, val)
    valueById


  deduceMinValue = (data, valueProperty, allMappingPropertiesOnMap, mappingPropertyOnData) ->
    minValue = d3.min data, (d) ->
      propertyOnData = d[mappingPropertyOnData]
      if allMappingPropertiesOnMap.indexOf(propertyOnData) != -1
        +d[valueProperty]


  deduceMaxValue = (data, valueProperty, allMappingPropertiesOnMap, mappingPropertyOnData) ->
    d3.max data, (d) ->
      propertyOnData = d[mappingPropertyOnData]
      if allMappingPropertiesOnMap.indexOf(propertyOnData) != -1
        +d[valueProperty]


  # either quantize or ordinal depending on type of data
  deduceValueFunction = (scope, colorSteps, allMappingPropertiesOnMap) ->
    mapInstance = mapMediatorService.getUIModel(scope.mapId)
    if mapInstance.getValueType() == 'categorical'
      categoryValues = mapInstance.getCategoryValues()
      valFn = d3.scale.ordinal()
        .domain(categoryValues)
        .range(d3.range(categoryValues.length).map (i) ->
          "q#{i}-#{categoryValues.length}"
        )
    else
      maxValue = deduceMaxValue(scope.data, scope.valueProperty, allMappingPropertiesOnMap, scope.mappingPropertyOnData)
      minValue = deduceMinValue(scope.data, scope.valueProperty, allMappingPropertiesOnMap, scope.mappingPropertyOnData)
      valFn = d3.scale.quantize()
        .domain([minValue, maxValue])
        .range(d3.range(colorSteps).map (i) ->
          "q#{i}-#{colorSteps}"
        )

    return valFn


  #    #############################################
  #      Legend Rendering
  #    #############################################

  renderLegend = (scope, valFn) ->
    # reset current legend
    scope.legend.selectAll('li.key')
        .data([])
      .exit().remove()

    # find out which type of data we have
    mapInstance = mapMediatorService.getUIModel(scope.mapId)
    isCategorical = mapInstance.getValueType() == 'categorical'

    if isCategorical
      genericLegendRender(scope, $.proxy(filterDataForCategoricalLegend, this, mapInstance, valFn),
      (d) ->
        d.value
      , (d) ->
        d.key
      )
    else
      genericLegendRender(scope, valFn.range, (d) ->
        extent = valFn.invertExtent(d)
        "#{Math.round(10*extent[0])/10} – #{Math.round(10*extent[1])/10}"
      , (d) ->
        d
      )


  genericLegendRender = (scope, dataFn, textFn, classFn) ->
    scope.legend.selectAll('li.key')
        .data(dataFn())
      .enter().append('li')
        .attr('class', 'key')
        .text( (d) -> textFn(d) )
      .append('svg')
        .attr('height', 30)
      .append('rect')
        .attr('width', '100%')
        .attr('height', 10)
        .attr('y', 10)
        .attr('x', (d, index) -> $(this).outerWidth() * index)
        .attr('class', (d) -> classFn(d) )


  # Filter out categorical values that are not shown on the map
  filterDataForCategoricalLegend = (mapInstance, valFn) ->
    data = []
    dataUsed = mapInstance.usedDataValues
    for entry, index in valFn.range()
      category = valFn.domain()[index]
      if dataUsed.indexOf(category) != -1
        data.push
          key: entry
          value: category
    data


  #    #############################################
  #      Utilities
  #    #############################################

  # gets all mapped property values that are actually on the map
  deduceAllAvailableMappingOnMap = (map, mappingPropertyOnMap) ->
    map.features.map (mapEntry) ->
      mapEntry.properties[mappingPropertyOnMap]


  # Stop progress bar with a timeout to prevent running conditions
  stopProgressBar = ->
    $timeout ->
      ngProgress.complete()
    , 1000


  #    #############################################
  #      Directive Literal
  #    #############################################

  return {
    restrict: 'EA'
    scope: {
      mapId: '=mapId' # the id of the map instance
      map: '=map' # the map to draw
      lastPositioned: '=lastPositioned' # timestamp when the maps container (width) changes
      projection: '=projection' # the projection applied to the map
      data: '=data' # data that should be visualized on the map
      mappingPropertyOnMap: '=mappingPropertyOnMap' # the property on the map that is used to map upon data
      mappingPropertyOnData: '=mappingPropertyOnData' # the property on the data that is used to map upon the map
      valueProperty: '=valueProperty' # the (numerical) data value to visualize
      colorSteps: '=colorSteps' # how many quantize steps the visualization will have
      colorScheme: '=colorScheme' # the color brewer color scheme to use
    }
    replace: true
    template: "<div style='position:relative' class='choropleth-map'></div>"
    link: (scope, element, attrs) ->
      # set up color scheme
      d3.select(element[0])
        .attr('class', scope.colorScheme)

      scope.legend = d3.select(element[0])
      .append('ul')
        .attr('class', 'list-inline')

      # set up initial svg object
      scope.svg = d3.select(element[0])
        .append('svg')
          .attr('width', '100%')
          .attr('height', '0px')
          .attr('class', 'choropleth')

      scope.mapGroup = scope.svg.append('g')
        .attr('class', 'map')

      $(element).append("""
        <img class="placeholder-image" src="http://placehold.it/#{$(element).width()}x200}/F55CB7/ffffff&text=select%20this%20snippet%20and%20choose%20a%20map%20in%20the%20sidebar" />
      """)


      #    #############################################
      #      Change Listeners
      #    #############################################

      scope.$watch('map', (newVal, oldVal) ->
        return unless newVal
        $placeholder = $(element).find('.placeholder-image')
        $placeholder.remove() if $placeholder
        if newVal != oldVal # to prevent init redraw
          removeExistingMap(scope.mapGroup)
          renderVisualization(scope)
          stopProgressBar()
      )

      # NOTE: watches on object equality not reference equality
      scope.$watch('data', (newVal, oldVal) ->
        return unless newVal && scope.map
        if newVal != oldVal # to prevent init redraw
          renderVisualization(scope)
          stopProgressBar()
      , true)

      scope.$watch('lastPositioned', (newVal, oldVal) ->
        return unless scope?.map
        if newVal != oldVal # to prevent init redraw
          renderVisualization(scope)
          stopProgressBar()
      )

      scope.$watch('projection', (newVal, oldVal) ->
        return unless scope?.map
        if newVal != oldVal
          removeExistingMap(scope.mapGroup)
          renderVisualization(scope)
          stopProgressBar()
      )

      # TODO: only re-render data here
      scope.$watch('mappingPropertyOnMap', (newVal, oldVal) ->
        # only re-render map when all necessary values are set
        #return unless scope?.map && scope?.mappingPropertyOnData && scope?.valueProperty
        if newVal != oldVal
          renderVisualization(scope)
          stopProgressBar()
      )

      # TODO: only re-render data here
      scope.$watch('mappingPropertyOnData', (newVal, oldVal) ->
        # only re-render map when all necessary values are set
        #return unless scope?.map && scope?.mappingPropertyOnMap && scope?.valueProperty
        if newVal != oldVal
          renderVisualization(scope)
          stopProgressBar()
      )

      # TODO: only re-render data here
      scope.$watch('valueProperty', (newVal, oldVal) ->
        # only re-render map when all necessary values are set
        #return unless scope?.map && scope?.mappingPropertyOnData && scope?.mappingPropertyOnMap
        if newVal != oldVal
          renderVisualization(scope)
          stopProgressBar()
      )

      scope.$watch('colorScheme', (newVal, oldVal) ->
        return unless scope.map && scope.data
        if newVal
          d3.select(element[0])
            .attr('class', newVal)
      )

      # TODO: only re-render data here
      scope.$watch('colorSteps', (newVal, oldVal) ->
        return unless scope.map && scope.data
        if newVal
          renderVisualization(scope)
          stopProgressBar()
      )

  }
