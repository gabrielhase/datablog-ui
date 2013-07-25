describe 'ldWatsonApi: documentService', ->

  beforeEach ->
    module('ldWatsonApi')
    inject ($injector) =>
      @documentService = $injector.get('documentService')
      @$httpBackend = $injector.get('$httpBackend')

      @$httpBackend.when('GET', '/articles/1').respond
        id: '1'
        title: 'Watson Story'
        state: 'new'
        revision: '1'
        updated_at: new Date()
        json:
          "content": [
            {
              "identifier": "watson.text_layout"
              "containers":
                "default": [
                  "identifier": "watson.title"
                  "editables": {}
                ]
            }
          ]
          "meta": {}

      @$httpBackend.when('POST', '/articles/1').respond
        revision: 2


  afterEach ->
    @$httpBackend.verifyNoOutstandingExpectation()
    @$httpBackend.verifyNoOutstandingRequest()


  it 'gets a document by id', ->
    @$httpBackend.expectGET('/articles/1')
    response = @documentService.get(1)
    response.then (document) ->
      expect(document.id).toEqual('1')
      expect(document.revision).toEqual(1)

    @$httpBackend.flush()


  it 'saves a document', ->
    document = new Document
      id: '1'
      title: 'Watson Story'
      state: 'new'
      revision: 1
      updated_at: new Date()
      json:
        "content": [
          {
            "identifier": "watson.text_layout"
            "containers":
              "default": [
                "identifier": "watson.title"
                "editables": {}
              ]
          }
        ]
        "meta": {}

    @$httpBackend.expectPOST('/articles/1')
    response = @documentService.save(document)
    response.then (data) ->
      expect(document.id).toEqual('1')
      expect(document.revision).toEqual(2)

    @$httpBackend.flush()


