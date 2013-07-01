# Cookies service that is used instead of angular.js $cookies service.
# The reason is that angular.js implementation always works on the main domain and
# we need subdomain support (at least for now). The implementation is extremely
# basic, the domain is fixed and the path is always /
angular.module('ldApi').service 'cookies',
class Cookies

  constructor: () ->
    # When working on localhost the domain has to be "", NULL, or False
    # Otherwise the domain value has to contain at least two '.'
    if upfront.variables.frontendDomain != ""
      @domain = ".#{upfront.variables.frontendDomain}"
    else
      @domain = ""


  get: (name) ->
    unescape(document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + escape(name).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) || null


  set: (name, value) ->
    if !name
      false
    document.cookie = "#{escape(name)}=#{escape(value)}; domain=#{@domain}; path=/"
    true


  remove: (name) ->
    document.cookie = "#{escape(name)}=; expires Thu, 01 Jan 1970 00:00:00 GMT; path=/"
