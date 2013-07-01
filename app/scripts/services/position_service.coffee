angular.module('ldEditor').factory 'positionService',

  ($document) ->

    mouseX = mouseY = 0

    $document.bind 'mousemove', (event) ->
      mouseX = event.pageX
      mouseY = event.pageY


    # Service
    # -------

    mouse: ->
      return {
        x: mouseX
        y: mouseY
      }
