angular.module('ldEditor').directive 'choropleth', ($timeout, ngProgress) ->

  svg = null
  mapGroup = null

  defaults =
    colorSteps: 9
    mappingValue:
      inMap: 'properties.id'
      inData: 'id'


  # sets the viewBox attribute on the svg element to cover the whole map
  # dynamically adjusts the snippet height to the ratio to the viewBox
  resizeMap = ->
    svgHeight = svg.node().getBBox().height
    svgWidth = svg.node().getBBox().width
    svg.attr('viewBox', "0 0 #{svgWidth} #{svgHeight}")
    ratio = $(svg.node()).width() / svgWidth
    svg.attr('height', ratio * svgHeight)


  renderDataMap = (scope, map, data) ->
    path = d3.geo.path()

    mapPaths = mapGroup.selectAll('path')
        .data(map.features)
    mapPaths.enter().append('path')
      .attr('d', d3.geo.path())
    mapPaths.exit().remove()
    resizeMap()

    if data
      quantize = d3.scale.quantize()
        .domain([0, d3.max(data, (d) -> d.value)])
        .range(d3.range(defaults.colorSteps).map (i) ->
          "q#{i}-9"
        )
      valueById = d3.map()
      data.forEach (d) ->
        # TODO: for now id's are always numeric -> make this an interface property
        # TODO: make value an interface property
        valueById.set(+eval("d.#{defaults.mappingValue.inData}"), +d.value)
      mapGroup.selectAll('path')
        .attr('class', (d) -> quantize(valueById.get(+eval("d.#{defaults.mappingValue.inMap}"))))
        # TODO: use default value when quantize does not return a value


  # Stop progress bar with a timeout to prevent running conditions
  stopProgressBar = ->
    $timeout ->
      ngProgress.complete()
    , 1000


  return {
    restrict: 'EA'
    scope: {
      data: '=data'
      map: '=map'
      lastPositioned: '=lastPositioned'
    }
    replace: true
    template: "<div style='position:relative' class='choropleth-map'></div>"
    link: (scope, element, attrs) ->
      # set up initial svg object
      svg = d3.select(element[0])
        .append("svg")
          .attr("width", '100%')
          .attr("height", '0px')
      mapGroup = svg.append("g")
        .attr('class', 'map')

      $(element).append("""
        <img class="placeholder-image" src="http://placehold.it/#{$(element).width()}x200}/F55CB7/ffffff&text=select%20this%20snippet%20and%20choose%20a%20map%20in%20the%20sidebar" />
      """)

      scope.$watch('map', (newVal, oldVal) ->
        return unless newVal
        $placeholder = $(element).find('.placeholder-image')
        $placeholder.remove() if $placeholder
        if newVal != oldVal # to prevent init redraw
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
  }
