describe 'Map', ->

  describe 'populating data from snippet model', ->

    beforeEach ->
      @map = new Map
      @scope = {}
      @snippetModel =
        data: (type) ->
          if type == 'geojson'
            return { someData: 'this would be geojson' }
          if type == 'popupContentProperty'
            return { popupContentProperty: 'name' }


    it 'does populate the scope with the snippet models data', ->
      @map.populateData(@snippetModel, @scope)
      expect(@scope.geojson.data).to.eql(@snippetModel.data('geojson'))
      expect(@scope.geojson.popupContentProperty).to.eql(@snippetModel.data('popupContentProperty'))
