angular.module('ldEditor').controller 'FlowtextOptionsController',
class FlowtextOptionsController

  constructor: ($scope, uiStateService, editableEventsService) ->
    # UI State
    $scope.isBold = editableEventsService.isCurrentSelectionBold()
    $scope.isItalic = editableEventsService.isCurrentSelectionItalic()
    $scope.isLinked = editableEventsService.isCurrentSelectionLinked()
    $scope.linkMode = false

    $scope.selectBlockLevel = => @selectBlockLevel(uiStateService)
    $scope.toggleBold = => @toggleBold($scope, editableEventsService)
    $scope.toggleItalic = => @toggleItalic($scope, editableEventsService)
    $scope.toggleLink = => @toggleLink($scope, editableEventsService, uiStateService)


  selectBlockLevel: (uiStateService) ->
    # TODO: change selection to whole block


  toggleBold: (scope, editableEventsService) ->
    editableEventsService.toggleCurrentSelectionBold()
    scope.isBold = editableEventsService.isCurrentSelectionBold()


  toggleItalic: (scope, editableEventsService) ->
    editableEventsService.toggleCurrentSelectionItalic()
    scope.isItalic = editableEventsService.isCurrentSelectionItalic()


  toggleLink: (scope, editableEventsService, uiStateService) ->
    if editableEventsService.isCurrentSelectionLinked()
      editableEventsService.toggleCurrentSelectionLink()
      scope.isLinked = editableEventsService.isCurrentSelectionLinked()
    else
      # in link mode, set the link otherwise prepare link selection and
      # activate link mode.
      if scope.linkMode
        editableEventsService.toggleCurrentSelectionLink(scope.link)
        scope.linkMode = false
        uiStateService.set('flowtextPopover', false)
      else
        editableEventsService.expandCurrentSelectionToWord()
        scope.linkMode = true
