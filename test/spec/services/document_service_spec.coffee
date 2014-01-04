describe 'DocumentService', ->

  revision0 = {
    content: [
      {
        "identifier": "livingmaps.choropleth"
        "data": {"projection": "mollweide"}
      }
    ]
    meta: {}
  }

  revision1 = {
    content: [
      {
        "identifier": "livingmaps.choropleth"
        "data": {"projection": "mercator"}
      }
    ]
    meta: {}
  }

  before ->
    sinon.stub(doc.stash, 'get').returns(revision1)
    sinon.stub(doc.stash, 'list').returns('[
      {
        "key": "stash-88su224lal8",
        "date": "Fri Jan 03 2014 13:19:29 GMT+0100 (CET)"
      },
      {
        "key": "stash-2chqm3vbjqn",
        "date": "Fri Jan 03 2014 14:19:36 GMT+0100 (CET)"
      }
    ]')
    sinon.stub(doc.stash, 'getAll').returns([revision0, revision1])

  beforeEach ->
    @service = retrieveService('documentService')


  it 'gets the history', (done) ->
    @service.getHistory().then (history) ->
      expect(history).to.eql([
        {
          revisionId: 1
          userId: 8
          lastChanged: '2013-11-16 22:02:15'
        },
        {
          revisionId: 0
          userId: 8
          lastChanged: '2013-11-16 22:02:15'
        }
      ])
      done()
    retrieveService('$rootScope').$digest()


  it 'gets revision 1', (done) ->
    @service.getRevision(15, 1).then (revision) ->
      expected = new Document
        id: 15
        revisionNumber: 1
        title: 'Test Story'
        data: revision1
        updatedAt: '2013-11-01 10:11:32'
      expect(revision).to.eql expected

      done()
    retrieveService('$rootScope').$digest()


  it 'gets revision 0', (done) ->
    @service.getRevision(15, 0).then (revision) ->
      expected = new Document
        id: 15
        revisionNumber: 0
        title: 'Test Story'
        data: revision0
        updatedAt: '2013-11-01 10:11:32'
      expect(revision).to.eql expected
      done()
    retrieveService('$rootScope').$digest()
