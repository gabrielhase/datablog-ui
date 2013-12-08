angular.module('ldEditor').controller 'ChoroplethMapController',
class ChoroplethMapController

  constructor: (@$scope, @ngProgress, @mapMediatorService, @$timeout) ->
    @dataWasSet = $.Callbacks('memory once')

    @choroplethMapInstance = @mapMediatorService.getUIModel(@$scope.mapId)
    @snippetModel = @mapMediatorService.getSnippetModel(@$scope.mapId)

    @snippetModel.data
      lastPositioned: (new Date()).getTime()

    @setupKickstarters()
    @setupSnippetChangeListener()
    @$timeout => # the timeout makes sure that the choropleth property listeners are already setup
      @initScope()


  setupKickstarters: ->
    for property, propertyValue of choroplethMapConfig.kickstartProperties
      unless @snippetModel.data(property)
        kickstartProperty = {}
        kickstartProperty["#{property}"] = propertyValue
        @snippetModel.data(kickstartProperty)
    @initValuePropertyCallback()


  # init value to the first numeric property or the last property if none are
  # numeric.
  initValuePropertyCallback: ->
    @dataWasSet.add =>
      unless @snippetModel.data('valueProperty')
        for key, value of @snippetModel.data('data')[0]
          if $.isNumeric(value)
            @snippetModel.data
              valueProperty: key
            @initColorScheme() # once the value property is triggered, trigger the color scheme
            return
        @snippetModel.data
          valueProperty: key
      else
        @initColorScheme()


  initColorScheme: ->
    if @choroplethMapInstance.getValueType() == 'numerical'
      @snippetModel.data
        colorScheme: 'OrRd'
        colorSteps: 9
    else
      @snippetModel.data
        colorScheme: 'Paired'


  initScope: ->
    for trackedProperty in choroplethMapConfig.trackedProperties
      propertyValue = @snippetModel.data(trackedProperty)
      if propertyValue
        @$scope[trackedProperty] = propertyValue
        @handleKickstartCallbacks(trackedProperty)


  setupSnippetChangeListener: ->
    doc.snippetDataChanged (snippet, changedProperties) =>
      if snippet.id == @snippetModel.id
        @changeChoroplethAttrsData(changedProperties)


  changeChoroplethAttrsData: (changedProperties) ->
    for trackedProperty in choroplethMapConfig.trackedProperties
      if changedProperties.indexOf(trackedProperty) != -1
        newVal = @snippetModel.data(trackedProperty)
        if newVal
          if @ngProgress.status() == 0 && @choroplethMapInstance.shouldRenderLoadingBar(trackedProperty)
            @ngProgress.start()
            @ngProgress.set(10)
          @$scope[trackedProperty] = newVal
          @handleKickstartCallbacks(trackedProperty)


  handleKickstartCallbacks: (changedProperty) ->
    if changedProperty == 'data'
      @dataWasSet.fire()
    # once the user has set the color scheme manually the callbacks should never trigger
    @dataWasSet.disable() if changedProperty == 'valueProperty'


