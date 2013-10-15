angular.module('ldEditor').directive 'jsonUpload', ->


  return {
    restrict: 'A'
    scope:
      'callback': '&'
      'type': '@'
    link: (scope, element, attrs) ->
      reader = new FileReader()

      reader.onload = (aFile) =>
        try
          json = JSON.parse(aFile.target.result)
        catch e
          scope.callback
            data: null
            error:
              type: 'wrongFileFormat'
              message: 'This does not seem to be a json file.'
          return

        scope.callback
          data: json
          error: {}

      element.bind 'change', ->
        files = element.prop('files')
        file = files[0]
        reader.readAsText(file)
  }
