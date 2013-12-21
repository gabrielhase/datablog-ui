describe.only 'MapKickstartModalController', ->
  beforeEach ->
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


  describe 'changes', ->
    beforeEach ->
      @mapKickstartModalController = instantiateController('MapKickstartModalController',
        $scope: @scope, $modalInstance: @modalInstance, data: zurichCargoPins)


    it 'changes the text property on all pins when changing the global text property', ->
      @scope.globalValues.textProperty = 'PLZ'
      @scope.$digest()
      for marker in @scope.markers
        expect(marker.selectedTextProperty).to.equal('PLZ')


