angular.module('ldEditor').directive 'choropleth', ($timeout) ->

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
    svg.attr('height', ratio * $(svg.node()).height())


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
      mapGroup = svg.append("g")
        .attr('class', 'map')

      scope.$watch('map', (newVal, oldVal) ->
        return unless newVal
        element.findIn('.choropleth-map').append("""
          <img id='loader' style="position: absolute; top: 100px; left: 300px;" src="images/ajax-loader.gif"></img>
        """)
        $timeout ->
          renderDataMap(scope, newVal, scope.data)
          $(element).find('#loader').remove()
        , 100
      )

      scope.$watch('data', (newVal, oldVal) ->
        return unless newVal && scope.map
        renderDataMap(scope, scope.map, newVal)
      )

      scope.$watch('lastPositioned', (newVal, oldVal) ->
        return unless scope?.map
        renderDataMap(scope, scope.map, scope.data)
      )
  }
