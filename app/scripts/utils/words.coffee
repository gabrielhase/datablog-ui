# String Helpers
# --------------
# inspired by [https://github.com/epeli/underscore.string]()
@livingmapsWords = do ->

  # convert 'camelCase' to 'camel-case'
  snakeCase: (str) ->
    $.trim(str).replace(/([A-Z])/g, '-$1').replace(/[-_\s]+/g, '-').toLowerCase()

  # convert 'camelCase to camel case'
  wordize: (str) ->
    $.trim(str).replace(/([A-Z])/g, '-$1').replace(/[-_\s]+/g, ' ').toLowerCase()


  camelCase: (str) ->
    trimmedString = $.trim(str)
    words = trimmedString.split(' ')
    capitalizedWords = words.map (word) -> "#{word.charAt(0).toUpperCase()}#{word.substr(1).toLowerCase()}"
    capitalizedWords.join('')
