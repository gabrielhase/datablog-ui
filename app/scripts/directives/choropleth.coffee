angular.module('ldEditor').directive 'choropleth', ($timeout, ngProgress) ->

  defaults =
    projection: 'mercator'
    colorSteps: 9
    mappingPropertyOnMap: 'id'
    mappingPropertyOnData: 'id'
    valueProperty: 'value'

  # sets the viewBox attribute on the svg element to cover the whole map
  # dynamically adjusts the snippet height to the ratio to the viewBox
  resizeMap = (svg, bounds) ->
    svgHeight = bounds[1][1] - bounds[0][1]
    svgWidth = bounds[1][0] - bounds[0][0]
    svg.attr('viewBox', "#{bounds[0][0]} #{bounds[0][1]} #{svgWidth} #{svgHeight}")
    ratio = $(svg.node()).width() / svgWidth
    svg.attr('stroke-width', (1 / ratio) )
    svg.attr('height', ratio * svgHeight)


  removeExistingMap = (mapGroup) ->
    mapPaths = mapGroup.selectAll('path')
      .data([])
    mapPaths.exit().remove()


  renderDataMap = (scope, map, data) ->
    if scope.projection
      path = d3.geo.path().projection(eval("d3.geo.#{scope.projection}()"))
    else
      path = d3.geo.path().projection(eval("d3.geo.#{defaults.projection}()"))

    mapPaths = scope.mapGroup.selectAll('path')
        .data(map.features)
    mapPaths.enter().append('path')
      .attr('d', path)

    bounds =  path.bounds(map)
    resizeMap(scope.svg, bounds)

    if data
      quantize = d3.scale.quantize()
        .domain([0, d3.max(data, (d) ->
          +d[scope.valueProperty] || +d[defaults.valueProperty])])
        .range(d3.range(defaults.colorSteps).map (i) ->
          "q#{i}-9"
        )
      valueById = d3.map()
      data.forEach (d) ->
        dataPropertyId = d[scope.mappingPropertyOnData] || +d[defaults.mappingPropertyOnData]
        val = +d[scope.valueProperty] || +d[defaults.valueProperty]
        valueById.set(dataPropertyId, val)
      scope.mapGroup.selectAll('path')
        .attr('class', (d) ->
          mapPropertyId = d.properties[scope.mappingPropertyOnMap] || +d.properties[defaults.mappingPropertyOnMap]
          quantize(valueById.get(mapPropertyId))
        )
        # TODO: use default value when quantize does not return a value


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
    }
    replace: true
    template: "<div style='position:relative' class='choropleth-map'></div>"
    link: (scope, element, attrs) ->
      # set up initial svg object
      scope.svg = d3.select(element[0])
        .append("svg")
          .attr("width", '100%')
          .attr("height", '0px')
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
          renderDataMap(scope, newVal, scope.data)
          stopProgressBar()
      )

      scope.$watch('data', (newVal, oldVal) ->
        return unless newVal && scope.map
        if newVal != oldVal # to prevent init redraw
          renderDataMap(scope, scope.map, newVal)
          stopProgressBar()
      )

      scope.$watch('lastPositioned', (newVal, oldVal) ->
        return unless scope?.map
        if newVal != oldVal # to prevent init redraw
          renderDataMap(scope, scope.map, scope.data)
          stopProgressBar()
      )

      scope.$watch('projection', (newVal, oldVal) ->
        return unless scope?.map
        if newVal != oldVal
          removeExistingMap(scope.mapGroup)
          renderDataMap(scope, scope.map, scope.data)
          stopProgressBar()
      )

      scope.$watch('mappingPropertyOnMap', (newVal, oldVal) ->
        # only re-render map when all necessary values are set
        #return unless scope?.map && scope?.mappingPropertyOnData && scope?.valueProperty
        if newVal != oldVal
          renderDataMap(scope, scope.map, scope.data)
          stopProgressBar()
      )

      scope.$watch('mappingPropertyOnData', (newVal, oldVal) ->
        # only re-render map when all necessary values are set
        #return unless scope?.map && scope?.mappingPropertyOnMap && scope?.valueProperty
        if newVal != oldVal
          renderDataMap(scope, scope.map, scope.data)
          stopProgressBar()
      )

      scope.$watch('valueProperty', (newVal, oldVal) ->
        # only re-render map when all necessary values are set
        #return unless scope?.map && scope?.mappingPropertyOnData && scope?.mappingPropertyOnMap
        if newVal != oldVal
          renderDataMap(scope, scope.map, scope.data)
          stopProgressBar()
      )
  }
