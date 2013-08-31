angular.module('ldLocalApi').factory 'imageService', ($q) ->

  payload =
    info:
      count: 10
      pages: 5
      page: 1
    items: [
      {
        Image:
          caption: "The First Family listens as Colbie Caillat sings the National Anthem before the White House Easter Egg Roll on the South Lawn of the White House in Washington, DC, USA, on 25 April 2011. From left are First Lady Michelle Obama, U.S. President Barack Obama, daughters Sasha, and Malia and Micheles mother Marian Robinson. EPA/ROGER L. WOLLENBERG / POOL↵Ort: WASHINGTON, United States"
          original: "http://api:api9280@aurakel.ch/img/middle/2013/08/07/20130807_mHAWNZpPYiUzOsl_EZyRMg.jpg"
          photographer: "Obama Himself"
          source: "KEYSTONE"
          thumbnail: "http://api:api9280@aurakel.ch/img/thumb/2013/08/07/20130807_mHAWNZpPYiUzOsl_EZyRMg.jpg"
          x_axis: 1000
          y_axis: 585
      }
      , {
        Image:
          caption: " An undated handout photograph released by Sony Corp. of conductor ex-Sony manager Norio Ohga who died in Tokyo, Japan, on 23 April, 2011. Ohga was responsible for the introduction of the music-cd and the playstation. EPA/SONY HANDOTU HANDOUT EDITORIAL USE ONLY/NO SALES"
          original: "http://api:api9280@aurakel.ch/img/middle/2013/08/07/20130807_9at30pBKmcaTecbg5hlOag.jpg"
          photographer: "Sepp Maier"
          source: "Leser-Reporter"
          thumbnail: "http://api:api9280@aurakel.ch/img/thumb/2013/08/07/20130807_9at30pBKmcaTecbg5hlOag.jpg"
          x_axis: 665
          y_axis: 1000
      }, {
        Image:
          caption: "US actor Jaden Smith watches his sister Willow Smith (not pictured) perform on the South Lawn of the White House during the annual Easter Egg Roll, in Washington DC, USA, 25 April 2011. Thousands of children participate in the event, which dates back to 1878, and is named for races where children push colored eggs across the grass using wooden spoons. EPA/MICHAEL REYNOLDS"
          original: "http://api:api9280@aurakel.ch/img/middle/2013/08/07/20130807_ZdQMXTW9Qdkl10xuIwysPQ.jpg"
          photographer: "Jimmy Wales"
          source: "Wikipedia"
          thumbnail: "http://api:api9280@aurakel.ch/img/thumb/2013/08/07/20130807_ZdQMXTW9Qdkl10xuIwysPQ.jpg"
          x_axis: 666
          y_axis: 1000
      }, {
        Image:
          caption: "== With AFP Story by Karin ZEITVOGEL: Entertainment-sport-basket-US-Globetrotters,FEATURE == Hi-Lite Bruton (R) and Scooter Christensen (C) of the Harlem Globetrotters watch a little girl balancing a ball on her finger during a game against the Washinton Generals at the Verizon Center in Washington on March 5, 2011. AFP PHOTO/Nicholas KAMM "
          original: "http://api:api9280@aurakel.ch/img/middle/2013/08/07/20130807_te0_m1oPnIazlqfkbC5EOQ.jpg"
          photographer: "Hans Muster"
          source: "Leser-Reporter"
          thumbnail: "http://api:api9280@aurakel.ch/img/thumb/2013/08/07/20130807_te0_m1oPnIazlqfkbC5EOQ.jpg"
          x_axis: 1000
          y_axis: 806
      }, {
        Image:
          caption: " The First Family listens as Colbie Caillat sings the National Anthem before the White House Easter Egg Roll on the South Lawn of the White House in Washington, DC, USA, on 25 April 2011. From left are First Lady Michelle Obama, U.S. President Barack Obama, daughters Sasha, and Malia and Micheles mother Marian Robinson. EPA/ROGER L. WOLLENBERG / POOL↵Ort: WASHINGTON, United States"
          original: "http://api:api9280@aurakel.ch/img/middle/2013/08/07/20130807_mHAWNZpPYiUzOsl_EZyRMg.jpg"
          photographer: "Obama Himself"
          source: "KEYSTONE"
          thumbnail: "http://api:api9280@aurakel.ch/img/thumb/2013/08/07/20130807_mHAWNZpPYiUzOsl_EZyRMg.jpg"
          x_axis: 1000
          y_axis: 585
      }, {
        Image:
          caption: "FC Barcelonas midfielder Andres Iniesta attends a press conference at Camp Nou stadium in Barcelona, Catalonia, northeastern Spain, 25 April 2011. FC Barcelona will fight against Real Madrid on 27 April 2011 during their semifinal Champions League soccer match at Santiago Bernabeu stadium in downtown Madrid. EPA/TONI ALBIR"
          original: "http://api:api9280@aurakel.ch/img/middle/2013/08/07/20130807_ux4fk6KA6ILygI7lyqaGDg.jpg"
          photographer: "a photographer"
          source: "KEYSTONE"
          thumbnail: "http://api:api9280@aurakel.ch/img/thumb/2013/08/07/20130807_ux4fk6KA6ILygI7lyqaGDg.jpg"
          x_axis: 1000
          y_axis: 694
      }, {
        Image:
          caption: " An undated handout photograph released by Sony Corp. of conductor ex-Sony manager Norio Ohga who died in Tokyo, Japan, on 23 April, 2011. Ohga was responsible for the introduction of the music-cd and the playstation. EPA/SONY HANDOTU HANDOUT EDITORIAL USE ONLY/NO SALES"
          original: "http://api:api9280@aurakel.ch/img/middle/2013/08/07/20130807_9at30pBKmcaTecbg5hlOag.jpg"
          photographer: "Sepp Maier"
          source: "Leser-Reporter"
          thumbnail: "http://api:api9280@aurakel.ch/img/thumb/2013/08/07/20130807_9at30pBKmcaTecbg5hlOag.jpg"
          x_axis: 665
          y_axis: 1000
      }, {
        Image:
          caption: "US actor Jaden Smith watches his sister Willow Smith (not pictured) perform on the South Lawn of the White House during the annual Easter Egg Roll, in Washington DC, USA, 25 April 2011. Thousands of children participate in the event, which dates back to 1878, and is named for races where children push colored eggs across the grass using wooden spoons. EPA/MICHAEL REYNOLDS"
          original: "http://api:api9280@aurakel.ch/img/middle/2013/08/07/20130807_ZdQMXTW9Qdkl10xuIwysPQ.jpg"
          photographer: "Jimmy Wales"
          source: "Wikipedia"
          thumbnail: "http://api:api9280@aurakel.ch/img/thumb/2013/08/07/20130807_ZdQMXTW9Qdkl10xuIwysPQ.jpg"
          x_axis: 666
          y_axis: 1000
      }, {
        Image:
          caption: "== With AFP Story by Karin ZEITVOGEL: Entertainment-sport-basket-US-Globetrotters,FEATURE == Hi-Lite Bruton (R) and Scooter Christensen (C) of the Harlem Globetrotters watch a little girl balancing a ball on her finger during a game against the Washinton Generals at the Verizon Center in Washington on March 5, 2011. AFP PHOTO/Nicholas KAMM "
          original: "http://api:api9280@aurakel.ch/img/middle/2013/08/07/20130807_te0_m1oPnIazlqfkbC5EOQ.jpg"
          photographer: "Hans Muster"
          source: "Leser-Reporter"
          thumbnail: "http://api:api9280@aurakel.ch/img/thumb/2013/08/07/20130807_te0_m1oPnIazlqfkbC5EOQ.jpg"
          x_axis: 1000
          y_axis: 806
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
