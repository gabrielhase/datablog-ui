angular.module('ldLocalApi').factory 'imageService', ($q) ->

  payload =
    info:
      count: 10
      pages: 5
      page: 1
    items: [
      {
        Image:
          caption: ""
          original: "http://images2.fanpop.com/images/photos/6900000/Felines-national-geographic-6909276-1600-1200.jpg"
          photographer: ""
          source: "National Geographics"
          thumbnail: "http://images2.fanpop.com/images/photos/6900000/Felines-national-geographic-6909276-800-600.jpg"
          x_axis: 1600
          y_axis: 1200
      }
      , {
        Image:
          caption: ""
          original: "http://www.nationalgeographic.it/images/2012/01/04/171836749-df3edcf8-41cf-4291-9749-14823411f329.jpg"
          photographer: ""
          source: "National Geographics"
          thumbnail: "http://www.nationalgeographic.it/images/2012/01/04/171836749-df3edcf8-41cf-4291-9749-14823411f329.jpg"
          x_axis: 1600
          y_axis: 1200
      }, {
        Image:
          caption: ""
          original: "http://fin6.com/wp-content/uploads/2013/08/9a2d5992d587a90de759fc8ecc25a63e.jpg"
          photographer: ""
          source: "National Geographics"
          thumbnail: "http://fin6.com/wp-content/uploads/2013/08/9a2d5992d587a90de759fc8ecc25a63e.jpg"
          x_axis: 1600
          y_axis: 1200
      }, {
        Image:
          caption: ""
          original: "http://s1.ibtimes.com/sites/www.ibtimes.com/files/styles/picture_this/public/2012/11/01/home-alone.jpg"
          photographer: ""
          source: "National Geographics"
          thumbnail: "http://s1.ibtimes.com/sites/www.ibtimes.com/files/styles/picture_this/public/2012/11/01/home-alone.jpg"
          x_axis: 1600
          y_axis: 1200
      }
    ]


  instantiateImage = (imageData) ->
    new Image
      caption: imageData.caption
      original: imageData.original
      photographer: imageData.photographer
      source: imageData.source
      thumbnail: imageData.thumbnail
      width: imageData.x_axis
      height: imageData.y_axis


  parseResponseData = (data) ->
    info: data.info
    images: instantiateImage(serverItem.Image) for serverItem in data.items


  deferralsResolver = (deferrals) ->
    (parsedData) ->
      for key, deferral of deferrals
        deferral.resolve(parsedData[key])


  extractPromises = (deferrals) ->
    promises = {}
    for key, deferral of deferrals
      promises[key] = deferral.promise

    promises


  get: (opts = {}) ->
    deferrals =
      images: $q.defer()
      info: $q.defer()

    parsedData = parseResponseData(payload)
    parsedData.info.page = opts.pageNo if opts.pageNo # just overwrite this for the local API
    deferralsResolver(deferrals)(parsedData)

    extractPromises(deferrals)
