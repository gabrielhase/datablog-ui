angular.module('ldLocalApi').factory 'documentService', ($q) ->

  docs = {}

  # Service
  # -------

  get: (id) ->
    documentPromise = $q.defer()

    docs[id] ||= new Document
      id: id
      title: 'Test Story'
      revisionNumber: 1
      updatedAt: new Date()
      data:
        "content": [
          {
            "identifier": "livingmaps.column"
            "containers":
              "default": [
                #"identifier": "livingmaps.unemploymentChoropleth"
                "identifier": "livingmaps.choropleth"
                "content": {"title": "US Unemployment"}
              ,
                "identifier": "livingmaps.title"
                "content": {"title": "livingmaps"}
              ]
          },
          {
           "identifier": "livingmaps.mainAndSidebar"
           "containers":
             "main": [
               "identifier": "livingmaps.title"
               "content":
                 "title": "The livingdocs.io manifesto"
              ,
               "identifier": "livingmaps.text"
               "content":
                 "text": "Shortly after its inception, the web was used by scientists at the major US universities to exchange and review papers and ideas. A web citizen was someone writing to the web and reading from the web."
              ,
               "identifier": "livingmaps.text"
               "content":
                 "text": "About 30 years and billions of dollars later this description holds true for less than 1 percent of web citizens. The spread of infrastructure to support the Internet world-wide is unprecedented. Yet for most people the primary means of producing content is still offline (e.g. Microsoft Word). This has serious implications: The expression of over 99 percent of people on the web is marginalized to Tweets and Facebook Status messages."
              ,
               "identifier": "livingmaps.text"
               "content":
                 "text": "Twitter is great (Facebook isn’t). Yet we wouldn’t readily accept the prospect of publishing our ideas solely on short messages (SMS). Let us continue to use Twitter for short messages. But more importantly: let us develop an open web publishing platform that everybody can use for all the other messages we have for the world."
              ,
               "identifier": "livingmaps.text"
               "content":
                 "text": "An open publishing platform is a way for people to publish documents on the web. Not PDF’s, real web documents. The tech talk of this is HTML, CSS, Javascript. The implications are interactive, expressive documents in the browser. The difference is that we want to enable the 99 percent of web citizens without adequate possibility to express themselves on the web to use nothing less than the most recent technology available to web browsers. Data Journalism, long-form articles, responsive design, you name it!"
              ,
               "identifier": "livingmaps.text"
               "content":
                 "text": "This is quite a mouthful. Livingdocs starts today at http://www.livingdocs.io . It’s to early to say where this journey will lead. But if you care about our vision then follow us @upfrontIO and we will send you short messages that hopefully one day will enable us to host your long messages."
             ],
             "sidebar": [
              "identifier": "livingmaps.image"
             ,
              "identifier": "livingmaps.map"
              "content":
                "title": "Holy crap this is an interactive map"
             ]
          }

        ]
        "meta": {}


    documentPromise.resolve(docs[id])
    documentPromise.promise


  save: (document) ->
    deferred = $q.defer()
    document.revisionNumber = document.revision + 1
    deferred.resolve(document)

    deferred.promise


  publish: (document) ->
    @save(document)
