angular.module('ldEditor').service 'mapMediatorService', ->

  registry = {}


  set: (id, snippetModel, uiModel, directiveScope) ->
    registry[id] =
      snippetModel: snippetModel
      uiModel: uiModel
      directiveScope: directiveScope


  getSnippetModel: (id) ->
    registry[id].snippetModel


  getUIModel: (id) ->
    registry[id].uiModel
