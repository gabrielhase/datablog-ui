angular.module('ldEditor').directive 'choropleth', ->

  return {
    restrict: 'A'
    scope: {}
    template: htmlTemplates.choroplethMap
    replace: true
  }
