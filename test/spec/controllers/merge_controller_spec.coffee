describe 'MergeController', ->

  beforeEach ->
    @snippetModel = doc.create('livingmaps.choropleth')
    @snippetModel.data
      map: biggerSampleMap
      data: sample1DData
      projection: 'mercator'
      mappingPropertyOnMap: 'id'
      valueProperty: 'value'
      colorScheme: 'YlGn'
    @olderSnippetModel = @snippetModel.copy(doc.document.design)
    @scope = retrieveService('$rootScope').$new()
    @scope.latestSnippetVersion = @snippetModel
    @scope.historyVersionSnippet = @olderSnippetModel
    @scope.modalState =
      isMerging: false
    @mapMediatorService = retrieveService('mapMediatorService')
    @choroplethMap = new ChoroplethMap
      id: @snippetModel.id
      mapMediatorService: @mapMediatorService
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @choroplethMap, {})
    @mergeController = instantiateController('MergeController', $scope: @scope,
      mapMediatorService: @mapMediatorService)
    @event =
      stopPropagation: ->
        true


  describe 'Merge Status', ->

    beforeEach ->
      @snippetModel.data
        projection: 'orthographic'
        map: smallerSampleMap
        mappingPropertyOnMap: 'alternativeId'
        valueProperty: 'alternativeValue'
        colorScheme: 'Set1'


    ['map', 'projection', 'mappingPropertyOnMap', 'valueProperty', 'colorScheme', 'quantizeStep'].forEach (key) ->
      it "enables the merge status on a change on #{key}", ->
        @mergeController.revertChange
          key: key
        expect(@scope.modalState.isMerging).to.be.true


  describe 'Map Section', ->

    beforeEach ->
      @snippetModel.data
        projection: 'orthographic'
        map: smallerSampleMap

    it 'reverts a change in map geometry', ->
      @mergeController.revertChange
        key: 'map'
      expect(@snippetModel.data('map')).to.eql(biggerSampleMap)


    it 'reverts a change in projection', ->
      @mergeController.revertChange
        key: 'projection'
      expect(@snippetModel.data('projection')).to.equal('mercator')


    # it 'merges a change in map geometry and projection', ->
    #   @mergeController.revertChange
    #     key: 'map'
    #   @mergeController.revertChange
    #     key: 'projection'
    #   @mergeController.merge(@event)
    #   expect()


  describe 'Mapping Section', ->

    beforeEach ->
      @snippetModel.data
        mappingPropertyOnMap: 'alternativeId'

    it 'reverts a change in mapping', ->
      @mergeController.revertChange
        key: 'mappingPropertyOnMap'
      expect(@snippetModel.data('mappingPropertyOnMap')).to.equal('id')


  describe 'Data Section', ->

    beforeEach ->
      @originalData = []
      @oneMoreRow = []
      @oneLessRow = []
      @addedRow =
        id: 99
        alternativeId: 199
        reverseId: 'String99'
        value: 99
        alternativeValue: 199
      $.extend(true, @originalData, @snippetModel.data('data'))
      $.extend(true, @oneMoreRow, @snippetModel.data('data'))
      $.extend(true, @oneLessRow, @snippetModel.data('data'))
      @oneMoreRow.push(@addedRow)
      @deletedRow = @oneLessRow.pop()

    describe 'Data Addition', ->

      beforeEach ->
        @snippetModel.data
          data: @oneMoreRow

      it 'reverts the addition of a row', ->
        @mergeController.revertAdd
          key: 'data'
          difference:
            type: 'add'
            unformattedContent: @addedRow
        expect(@snippetModel.data('data')).to.eql(@originalData)


    describe 'Data Deletion', ->

      beforeEach ->
        @snippetModel.data
          data: @oneLessRow

      it 'reverts the deletion of a row', ->
        @mergeController.revertDelete
          key: 'data'
          difference:
            type: 'delete'
            unformattedContent: @deletedRow
        expect(@snippetModel.data('data')).to.eql(@originalData)


  describe 'Visualization Section', ->

    beforeEach ->
      @snippetModel.data
        valueProperty: 'alternativeValue'
        colorScheme: 'Set1'


    it 'reverts a change in value property', ->
      @mergeController.revertChange
        key: 'valueProperty'
      expect(@snippetModel.data('valueProperty')).to.equal('value')


    it 'reverts a change in color scheme', ->
      @mergeController.revertChange
        key: 'colorScheme'
      expect(@snippetModel.data('colorScheme')).to.equal('YlGn')


  describe 'Ordinal Data', ->

    beforeEach ->
      @snippetModel.data
        valueProperty: 'reverseId'

    it 'does not display the revertChange button for a quantizeStep if the value property is ordinal', ->
      @scope.$digest()
      expect(@scope.valueType).to.equal('categorical')

