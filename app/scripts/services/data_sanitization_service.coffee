angular.module('ldEditor').factory 'dataSanitizationService', ->


  sanitizeCSV: (data) ->
    return unless data
    # remove empty lines
    sanitizedData = data.filter (entry) ->
      hasNonEmptyValues = false
      for key, value of entry
        if value != undefined && value != ''
          hasNonEmptyValues = true
      hasNonEmptyValues

    # remove thousand separators from string values
    sanitizedData = sanitizedData.map (entry) ->
      sanitizedEntry = {}
      for key, value of entry
        if typeof value == 'string'
          cleanedValue = value.replace("'", "")
          if _.isNaN(+cleanedValue)
            sanitizedEntry[key] = value
          else
            sanitizedEntry[key] = +cleanedValue
        else
          sanitizedEntry[key] = value
      sanitizedEntry

    sanitizedData
