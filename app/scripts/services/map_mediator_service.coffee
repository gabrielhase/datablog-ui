angular.module('ldEditor').service 'mapMediatorService', ->

  registry = {}


  set: (id, snippetModel, uiModel, directiveScope) ->
    registry[id] =
      snippetModel: snippetModel
      uiModel: uiModel
      directiveScope: directiveScope


  reset: (id) ->
    delete registry[id]


  getSnippetModel: (id) ->
    registry[id].snippetModel


  getUIModel: (id) ->
    registry[id].uiModel


  getScope: (id) ->
    registry[id].directiveScope
