describe 'WebMapMergeController', ->
  beforeEach ->
    @snippetModel = doc.create('livingmaps.map')
    doc.document.snippetTree.root.append(@snippetModel)
    @snippetModel.data
      tiles: 'some tiles'
      center:
        lat: 1
        lng: 1
        zoom: 12
      markers: [rocketMarker, shoppingMarker]
    @olderSnippetModel = @snippetModel.copy(doc.document.design)
    @scope = retrieveService('$rootScope').$new()
    @scope.latestSnippetVersion = @snippetModel
    @scope.historyVersionSnippet = @olderSnippetModel
    @scope.modalState =
      isMerging: false
    @scope.rightBeforeMerge = $.Callbacks('memory once')
    @scope.resetMarker = -> true
    @scope.modalContentReady = $.Callbacks('memory once')
    @scope.modalContentReady.fire()
    @mapMediatorService = retrieveService('mapMediatorService')
    @webMap = new WebMap(@snippetModel.id)
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @webMap, {})
    @mergeController = instantiateController('WebMapMergeController', $scope: @scope,
      mapMediatorService: @mapMediatorService)
    @event =
      stopPropagation: ->
        true


  describe 'Tile Layer', ->
    beforeEach ->
      @snippetModel.data
        tiles: 'new tiles'

    it 'reverts a change', ->
      @mergeController.revertChange
        key: 'tiles'
      expect(@snippetModel.data('tiles')).to.eql(@olderSnippetModel.data('tiles'))


  describe 'View Box', ->
    beforeEach ->
      @snippetModel.data
        center: 'new center'

    it 'reverts a change', ->
      @mergeController.revertChange
        key: 'center'
      expect(@snippetModel.data('center')).to.eql(@olderSnippetModel.data('center'))


  describe 'Markers', ->

    it 'reverts an addition of a marker', ->
      @snippetModel.data('markers').push(coffeeMarker)
      @mergeController.revertAdd
        key: 'markers'
        difference:
          type: 'add'
          unformattedContent: coffeeMarker
      expect(@snippetModel.data('markers')).to.eql(@olderSnippetModel.data('markers'))


    it 'reverts a deletion of a marker', ->
      @snippetModel.data
        markers: [rocketMarker]
      @mergeController.revertDelete
        key: 'markers'
        difference:
          type: 'delete'
          unformattedContent: shoppingMarker
      expect(@snippetModel.data('markers')).to.eql(@olderSnippetModel.data('markers'))


  describe 'Marker Changes', ->
    beforeEach ->
      @snippetModel.data
        markers: @olderSnippetModel.data('markers')


    it 'reverts an icon change', ->
      @snippetModel.data('markers')[0].icon.options.icon = 'another icon'
      @mergeController.revertChange
        key: 'markers'
        uuid: rocketMarker.uuid
      expect(@snippetModel.data('markers')[0].icon.options.icon).to.equal(@olderSnippetModel.data('markers')[0].icon.options.icon)


    it 'reverts a popover text change', ->
      @snippetModel.data('markers')[0].message = 'another message'
      @mergeController.revertChange
        key: 'markers'
        uuid: rocketMarker.uuid
      expect(@snippetModel.data('markers')).to.eql(@olderSnippetModel.data('markers'))


    it 'reverts a location change', ->
      @snippetModel.data('markers')[0].lat = 99
      @mergeController.revertChange
        key: 'markers'
        uuid: rocketMarker.uuid
      expect(@snippetModel.data('markers')[0].lat).to.equal(@olderSnippetModel.data('markers')[0].lat)


    it 'reverts only a change, not a delete', ->
      @snippetModel.data
        markers: [rocketMarker]
      @snippetModel.data('markers')[0].lat = 99
      @mergeController.revertChange
        key: 'markers'
        uuid: rocketMarker.uuid
      expect(@snippetModel.data('markers').length).to.equal(1)

