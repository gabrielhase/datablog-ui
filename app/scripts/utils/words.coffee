# String Helpers
# --------------
# inspired by [https://github.com/epeli/underscore.string]()
@words = do ->

  # convert 'camelCase' to 'camel-case'
  snakeCase: (str) ->
    $.trim(str).replace(/([A-Z])/g, '-$1').replace(/[-_\s]+/g, '-').toLowerCase()
