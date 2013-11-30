angular.module('ldEditor').controller 'FlowtextOptionsController',
class FlowtextOptionsController

  constructor: (@$scope, @uiStateService, @editableEventsService) ->
    # UI State
    @$scope.editableEventsService = @editableEventsService
    @$scope.currentSelectionStyles = @editableEventsService.currentSelectionStyles

    @$scope.toggleBold = $.proxy(@toggleBold, this)
    @$scope.toggleItalic = $.proxy(@toggleItalic, this)
    @$scope.openLinkInput = $.proxy(@openLinkInput, this)
    @$scope.setLink = $.proxy(@setLink, this)


  toggleBold: ->
    @editableEventsService.toggleCurrentSelectionBold()


  toggleItalic: ->
    @editableEventsService.toggleCurrentSelectionItalic()


  openLinkInput: ->
    @editableEventsService.editLink()

    # Hack to get the popover to re-evaluate the positioning.
    # When editing a link the popover can have a different
    # width and height.
    @$scope.textPopoverBoundingBox.timestamp = new Date().getTime()


  setLink: (link, target) ->
    # in link mode, set the link otherwise prepare link selection and
    # activate link mode.
    @editableEventsService.endLinkEditing()
    @editableEventsService.setCurrentSelectionLink(link, target)
    @uiStateService.set('flowtextPopover', false)
