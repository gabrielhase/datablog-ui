describe 'WebMapController', ->
  beforeEach ->
    window.L = mockLeaflet()
    @mapMediatorService = retrieveService('mapMediatorService')
    @snippetModel = doc.create('livingmaps.map')
    doc.document.snippetTree.root.append(@snippetModel)
    @webMap = new WebMap(@snippetModel.id)
    @scope = retrieveService('$rootScope').$new()
    @scope.mapId = @snippetModel.id
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @webMap, @scope)


  describe 'kickstart initializations', ->
    beforeEach ->
      @webMapController = instantiateController('WebMapController', $scope: @scope)

    it 'initializes the center to Zurich at zoom level 12', ->
      expect(@scope.center.lat).to.equal(47.388778)
      expect(@scope.center.lng).to.equal(8.541971)
      expect(@scope.center.zoom).to.equal(12)


  describe 'change listeners', ->
    beforeEach ->
      @webMapController = instantiateController('WebMapController', $scope: @scope)
      @changeMapAttrsData = sinon.spy(@webMapController, 'changeMapAttrsData')

    it 'recognizes a change in the center attribute', ->
      @snippetModel.data
        center:
          lat: 11
          lng: 12
          zoom: 13
      expect(@changeMapAttrsData).to.have.been.calledWith(['center'])


  describe 'directive scope updates', ->
    beforeEach ->
      @webMapController = instantiateController('WebMapController', $scope: @scope)

    it 'does not change the directive scope when changing an untracked property', ->
      scopeBefore = {}
      $.extend(true, scopeBefore, @scope)
      @snippetModel.data
        iAmUntracked: 'someVal'
      expect(@scope).to.eql(@scope)


    it 'changes the center scope attribute on a change', ->
      @snippetModel.data
        center:
          lat: 11
          lng: 12
          zoom: 13
      expect(@scope.center).to.eql(@snippetModel.data('center'))




