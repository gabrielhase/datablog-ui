describe.only 'WebMapMergeController', ->
  beforeEach ->
    @snippetModel = doc.create('livingmaps.map')
    doc.document.snippetTree.root.append(@snippetModel)
    @marker =
      lat: 1
      lng: 1
      uuid: 1
      icon:
        options:
          icon: 'some icon'
    @snippetModel.data
      tiles: 'some tiles'
      center: 'some center'
      markers: [@marker]
    @olderSnippetModel = @snippetModel.copy(doc.document.design)
    @scope = retrieveService('$rootScope').$new()
    @scope.latestSnippetVersion = @snippetModel
    @scope.historyVersionSnippet = @olderSnippetModel
    @scope.modalState =
      isMerging: false
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
    beforeEach ->
      # todo

    it 'reverts an addition of a marker', ->
      addedMarker =
        lat: 2
        lng: 2
        uuid: 2
        icon: 'a second icon'
      @snippetModel.data('markers').push(addedMarker)
      @mergeController.revertAdd
        key: 'markers'
        difference:
          type: 'add'
          unformattedContent: addedMarker
      expect(@snippetModel.data('markers')).to.eql(@olderSnippetModel.data('markers'))


    it 'reverts a deletion of a marker', ->
      @snippetModel.data
        markers: []
      @mergeController.revertDelete
        key: 'markers'
        difference:
          type: 'delete'
          unformattedContent: @marker
      expect(@snippetModel.data('markers')).to.eql(@olderSnippetModel.data('markers'))


  describe 'Marker Changes', ->
    beforeEach ->
      @snippetModel.data
        markers: @olderSnippetModel.data('markers')


    it 'reverts an icon change', ->
      @snippetModel.data('markers')[0].icon.options.icon = 'another icon'
      @mergeController.revertChange
        key: 'markers'
      expect(@snippetModel.data('markers')).to.eql(@olderSnippetModel.data('markers'))


    it 'reverts a popover text change'


    it 'reverts a location change'





