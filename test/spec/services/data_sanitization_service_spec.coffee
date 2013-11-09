describe 'dataSanitizationService', ->

  beforeEach ->
    @service = retrieveService('dataSanitizationService')
    @emptyLineData = [
        id: ''
        value: ''
      ,
        id: 1
        value: 5
      ]


  describe 'sanitizing csv data', ->

    it 'removes empty lines', ->
      sanitizedData = @service.sanitizeCSV(@emptyLineData)
      expect(sanitizedData).to.eql([
        id: 1
        value: 5
      ])


    it 'removes thousand separators from numbers'

