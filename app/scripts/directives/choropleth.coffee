angular.module('ldEditor').directive 'choropleth', ->

  return {
    restrict: 'EA'
    scope: {
      data: '=data'
      map: '=map'
    }
    template: htmlTemplates.choroplethMap
    replace: true
    link: (scope, element, attrs) ->
      # set up initial svg object
      svg = d3.select(element[0])
        .append("svg")
          .attr("width", '100%')
          .attr("height", '200px') #TODO find out how to define height
  }
