angular.module('ldEditor').directive 'csvUpload', ->


  return {
    restrict: 'A'
    scope:
      'callback': '&'
      'type': '@'
    link: (scope, element, attrs) ->
      reader = new FileReader()

      reader.onload = (aFile) =>
        try
          rows = d3.csv.parse(aFile.target.result)
          #json = JSON.parse(aFile.target.result)
        catch e
          scope.callback
            data: null
            error:
              type: 'wrongFileFormat'
              message: 'This does not seem to be a csv file.'
          return

        scope.callback
          data: rows
          error: {}

      element.bind 'change', ->
        files = element.prop('files')
        file = files[0]
        reader.readAsText(file)
  }
