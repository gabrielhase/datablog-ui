angular.module('ldEditor').directive 'choropleth', ->

  return {
    restrict: 'A'
    scope: {}
    template: angularTemplates.choroplethMap
    replace: true
  }
