angular.module('ldEditor').directive 'choropleth', ($timeout, ngProgress) ->

  defaults =
    projection: 'mercator'
    quantizeSteps: 9
    colorScheme: 'Paired'
    mappingPropertyOnMap: 'id'
    mappingPropertyOnData: 'id'
    valueProperty: 'value'

  # remove all paths from the svg
  # this is needed since d3 identifies by array index which is overlapping
  # across maps
  removeExistingMap = (mapGroup) ->
    mapPaths = mapGroup.selectAll('path')
      .data([])
    mapPaths.exit().remove()


  renderMap = (scope, map, path) ->
    mapPaths = scope.mapGroup.selectAll('path')
      .data(map.features)
    mapPaths.enter().append('path')
      .attr('d', path)


  renderData = (scope, data, mappingPropertyOnData, valueProperty, mappingPropertyOnMap, valFn) ->
    valueById = d3.map()
    data.forEach (d) ->
      dataPropertyId = d[mappingPropertyOnData] || +d[defaults.mappingPropertyOnData]
      val = +d[valueProperty] || +d[defaults.valueProperty]
      valueById.set(dataPropertyId, val)
    scope.mapGroup.selectAll('path')
      .attr('class', (d) ->
        mapPropertyId = d.properties[mappingPropertyOnMap] || +d.properties[defaults.mappingPropertyOnMap]
        valFn(valueById.get(mapPropertyId))
      )


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
      path = d3.geo.path().projection(eval("d3.geo.#{projection}()"))
    else
      path = d3.geo.path().projection(eval("d3.geo.#{defaults.projection}()"))

    return path


  deduceMinValue = (data, valueProperty, allMappingPropertiesOnMap, mappingPropertyOnData) ->
    minValue = d3.min data, (d) ->
      propertyOnData = d[mappingPropertyOnData] || d[defaults.mappingPropertyOnData]
      if allMappingPropertiesOnMap.indexOf(propertyOnData) != -1
        +d[valueProperty] || +d[defaults.valueProperty]


  deduceMaxValue = (data, valueProperty, allMappingPropertiesOnMap, mappingPropertyOnData) ->
    d3.max data, (d) ->
      propertyOnData = d[mappingPropertyOnData] || d[defaults.mappingPropertyOnData]
      if allMappingPropertiesOnMap.indexOf(propertyOnData) != -1
        +d[valueProperty] || +d[defaults.valueProperty]


  # for now fixed to quantize
  deduceValueFunction = (data, valueProperty, quantizeSteps, allMappingPropertiesOnMap, mappingPropertyOnData) ->
    maxValue = deduceMaxValue(data, valueProperty, allMappingPropertiesOnMap, mappingPropertyOnData)
    minValue = deduceMinValue(data, valueProperty, allMappingPropertiesOnMap, mappingPropertyOnData)
    valFn = d3.scale.quantize()
      .domain([minValue, maxValue])
      .range(d3.range(quantizeSteps).map (i) ->
        "q#{i}-#{quantizeSteps}"
      )

    return valFn


  # gets all mapped property values that are actually on the map
  # Either gets all from the set mappingProperty or gets all from the default
  # no mixing of default and set property!
  deduceAllAvailableMappingOnMap = (map, mappingPropertyOnMap) ->
    map.features.map (mapEntry) ->
      if mappingPropertyOnMap
        mapEntry.properties[mappingPropertyOnMap]
      else
        mapEntry.properties[defaults.mappingPropertyOnMap]


  renderVisualization = (scope) ->
    map = scope.map
    data = scope.data
    path = deducePathProjection(scope.projection)
    valueProperty = scope.valueProperty
    mappingPropertyOnMap = scope.mappingPropertyOnMap
    mappingPropertyOnData = scope.mappingPropertyOnData
    quantizeSteps = scope.quantizeSteps || defaults.quantizeSteps

    renderMap(scope, map, path)

    bounds =  path.bounds(map)
    resizeMap(scope.svg, bounds)

    if data
      allMappingPropertiesOnMap = deduceAllAvailableMappingOnMap(map, mappingPropertyOnMap)
      valFn = deduceValueFunction(data, valueProperty, quantizeSteps, allMappingPropertiesOnMap, mappingPropertyOnData)
      renderData(scope, data, mappingPropertyOnData, valueProperty, mappingPropertyOnMap, valFn)


  # Stop progress bar with a timeout to prevent running conditions
  stopProgressBar = ->
    $timeout ->
      ngProgress.complete()
    , 1000


  return {
    restrict: 'EA'
    scope: {
      map: '=map' # the map to draw
      lastPositioned: '=lastPositioned' # timestamp when the maps container (width) changes
      projection: '=projection' # the projection applied to the map
      data: '=data' # data that should be visualized on the map
      mappingPropertyOnMap: '=mappingPropertyOnMap' # the property on the map that is used to map upon data
      mappingPropertyOnData: '=mappingPropertyOnData' # the property on the data that is used to map upon the map
      valueProperty: '=valueProperty' # the (numerical) data value to visualize
      quantizeSteps: '=quantizeSteps' # how many quantize steps the visualization will have
      colorScheme: '=colorScheme' # the color brewer color scheme to use
    }
    replace: true
    template: "<div style='position:relative' class='choropleth-map'></div>"
    link: (scope, element, attrs) ->
      # set up initial svg object
      scope.svg = d3.select(element[0])
        .append("svg")
          .attr("width", '100%')
          .attr("height", '0px')
          .attr("class", scope.colorScheme || defaults.colorScheme)
      scope.mapGroup = scope.svg.append("g")
        .attr('class', 'map')

      $(element).append("""
        <img class="placeholder-image" src="http://placehold.it/#{$(element).width()}x200}/F55CB7/ffffff&text=select%20this%20snippet%20and%20choose%20a%20map%20in%20the%20sidebar" />
      """)

      scope.$watch('map', (newVal, oldVal) ->
        return unless newVal
        $placeholder = $(element).find('.placeholder-image')
        $placeholder.remove() if $placeholder
        if newVal != oldVal # to prevent init redraw
          removeExistingMap(scope.mapGroup)
          renderVisualization(scope)
          stopProgressBar()
      )

      scope.$watch('data', (newVal, oldVal) ->
        return unless newVal && scope.map
        if newVal != oldVal # to prevent init redraw
          renderVisualization(scope)
          stopProgressBar()
      )

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
          scope.svg.attr('class', newVal)
      )

      # TODO: only re-render data here
      scope.$watch('quantizeSteps', (newVal, oldVal) ->
        return unless scope.map && scope.data
        if newVal
          renderVisualization(scope)
          stopProgressBar()
      )

  }
