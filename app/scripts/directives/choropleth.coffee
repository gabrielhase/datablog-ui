angular.module('ldEditor').directive 'choropleth', ->

  svg = null
  mapGroup = null

  defaults =
    colorSteps: 9
    mappingValue:
      inMap: 'properties.id'
      inData: 'id'


  resizeMap = ->
    newHeight = svg.node().getBBox().height
    svg.attr('height', newHeight)


  renderDataMap = (scope, map, data) ->
    path = d3.geo.path()
    mapGroup.selectAll('path')
        .data(map.features)
      .enter().append('path')
        .attr('d', d3.geo.path())
    resizeMap()
    if data
      quantize = d3.scale.quantize()
        .domain([0, d3.max(data, (d) -> d.value)])
        .range(d3.range(defaults.colorSteps).map (i) ->
          "q#{i}-9"
        )
      valueById = d3.map()
      data.forEach (d) ->
        valueById.set(eval("d.#{defaults.mappingValue.inData}"), +d.value)
      mapGroup.selectAll('path')
        .attr('class', (d) -> quantize(valueById.get(eval("d.#{defaults.mappingValue.inMap}"))))

  return {
    restrict: 'EA'
    scope: {
      data: '=data'
      map: '=map'
    }
    replace: true
    template: "<div style='position:relative'></div>"
    link: (scope, element, attrs) ->
      # set up initial svg object
      svg = d3.select(element[0])
        .append("svg")
          .attr("width", '100%')
      mapGroup = svg.append("g")
        .attr('class', 'map')

      scope.$watch('map', (newVal, oldVal) ->
        return unless newVal
        # element.append("""
        #   <img id='loader' style="position: absolute; top: 100px; left: 300px;" src="images/ajax-loader.gif"></img>
        # """)
        renderDataMap(scope, newVal, scope.data)
        #$(element).find('#loader').remove()
      )

      scope.$watch('data', (newVal, oldVal) ->
        return unless newVal && scope.map
        renderDataMap(scope, scope.map, newVal)
      )
  }
