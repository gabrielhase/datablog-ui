describe 'MapKickstartModalController', ->
  beforeEach ->
    window.L = mockLeaflet()
    @scope = retrieveService('$rootScope').$new()
    @modalInstance =
      dismiss: ->
        true
    @event =
      stopPropagation: ->
        true


  describe 'initializations', ->
    beforeEach ->
      @mapKickstartModalController = instantiateController('MapKickstartModalController',
        $scope: @scope, $modalInstance: @modalInstance, data: zurichCargoPins)


    it 'recognizes all point geometries as potential pins', ->
      expect(@scope.markers.length).to.equal(11)


    it 'selects all pins by default', ->
      for marker in @scope.markers
        expect(marker.selected).to.be.true


    it 'gets the text properties for the first pin', ->
      expect(@scope.markers[0].textProperties).to.have.same.members(
        ['Ort', 'www', 'Adresse', 'PLZ', 'Tel', 'Name']
      )


    it 'gets the globally available text properties', ->
      expect(@scope.globalTextProperties).to.have.same.members(
        ['www', 'Adresse', 'PLZ', 'Tel', 'Name']
      )


    it 'initializes the maps center to the location of the first pin with zoom 8', ->
      expect(@scope.center).to.eql
        zoom: 8
        lng: 8.51172926978877
        lat: 47.3530684006283


    it 'initializes the preview markers', ->
      expect(@scope.previewMarkers.length).to.equal(11)


    it 'initializes the structure of a preview marker', ->
      console.log @scope.previewMarkers[0]
      expect(@scope.previewMarkers[0]).to.eql
        lng: 8.51172926978877
        lat: 47.3530684006283
        riseOnHover: true
        icon: 'default'


  describe 'changes', ->
    beforeEach ->
      @mapKickstartModalController = instantiateController('MapKickstartModalController',
        $scope: @scope, $modalInstance: @modalInstance, data: zurichCargoPins)


    it 'changes the text property on all pins when changing the global text property', ->
      @scope.globalValues.textProperty = 'PLZ'
      @scope.$digest()
      for marker in @scope.markers
        expect(marker.selectedTextProperty).to.equal('PLZ')


