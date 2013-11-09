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
    @thousandSeparatorData = [
      id: 1
      value: "100'000"
    ,
      id: 2
      value: "32'423.3"
    ]
    @apostrophesData = [
      id: 1
      value: "It's great"
    ,
      id: 2
      value: "Datablog'"
    ]


  describe 'sanitizing csv data', ->

    it 'removes empty lines', ->
      sanitizedData = @service.sanitizeCSV(@emptyLineData)
      expect(sanitizedData).to.eql([
        id: 1
        value: 5
      ])


    it 'removes thousand separators from numbers', ->
      sanitizedData = @service.sanitizeCSV(@thousandSeparatorData)
      expect(sanitizedData).to.eql([
        id: 1
        value: 100000
      ,
        id: 2
        value: 32423.3
      ])


    it 'does not remove apostrophes from categorical data', ->
      sanitizedData = @service.sanitizeCSV(@apostrophesData)
      expect(sanitizedData).to.eql([
        id: 1
        value: "It's great"
      ,
        id: 2
        value: "Datablog'"
      ])

