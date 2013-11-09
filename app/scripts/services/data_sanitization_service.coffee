angular.module('ldEditor').factory 'dataSanitizationService', ->


  sanitizeCSV: (data) ->
    return unless data
    sanitizedData = data.filter (entry) ->
      hasNonEmptyValues = false
      for key, value of entry
        if value != undefined && value != ''
          hasNonEmptyValues = true
      hasNonEmptyValues

    sanitizedData
