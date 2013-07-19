@upfront = @upfront || {}
@upfront.api = do ->

  # AJAX GET request
  # can be called with 2 or 3 params:
  # 3 params: "categories", { id: 5 }, ->
  # 2 params: "categories", ->
  get: (path, data, callback) ->
    if arguments.length == 2
      callback = data
      data = undefined
    @fakeLoad(path, data, callback)


  # simulate server
  fakeLoad: (path, data, callback) ->
    getResult = $.Deferred()
    # get simulated response
    response = switch path

      when "documents/1"
        # returns a user, a document, and a snippetTree
        {"user":{"email":"gabriel.hase@gmail.com","prename":"Gabriel","surname":"Hase","display_name":"Gabriel Hase"},"document":{"id":1,"title":"africa-story","state":"new","url":"http://watson.thelivingdoc.com/africa-story","updated_at":"2013-06-05T14:46:33.820Z"},"snippetTree":{"content":[{"identifier":"watson.text_layout","containers":{"default":[{"identifier":"watson.title","editables":{}}]}}],"meta":{}}}
      else
        {}

    # simulate server response time
    setTimeout( ->
      getResult.resolve(response, 200)
    , (Math.random() * 300 + 500) )

    # request simulated
    return getResult.promise()


  post: (path, data, callback, errorCallback) ->
    @fakePost(path, data, callback, errorCallback)


    # simulate server response
  fakePost: (page, data, callback, errorCallback) ->

    postResult = $.Deferred()
    # debug
    #console.log("request: #{ page }")
    #console.log(data) if console && console.log

    response = switch page
      when "documents/save"
       {}
      when "auth" # just authenticate, don't worry about real auth
        { "access_token": "rEsw4NZ2sxcy9aT6aWVdqyrTz7z8kMnP" }

    if response

      # simulate server response time
      setTimeout( ->

        # degub
        #console.log("response: #{ page }")
        #console.log(response) if console && console.log

        postResult.resolve(response, 200)
      , (Math.random() * 300 + 500) )

    return postResult.promise()
