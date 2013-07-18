# Configuration
# -------------
config = {
  wordSeparators: "./\\()\"':,.;<>~!#%^&*|+=[]{}`~?"
  attributePrefix: 'data'
}

# constants for classes used in a document
docClass =

  # document classes
  section: 'doc-section'

  # snippet classes
  snippet: 'doc-snippet'
  editable: 'doc-editable'
  interface: 'doc-ui'

  # highlight classes
  snippetHighlight: 'doc-snippet-highlight'
  containerHighlight: 'doc-container-highlight'

  # drag & drop
  draggedPlaceholder: 'doc-dragged-placeholder'
  dragged: 'doc-dragged'
  beforeDrop: 'doc-before-drop'
  afterDrop: 'doc-after-drop'

  # utility classes
  preventSelection: 'doc-no-selection'
  maximizedContainer: 'doc-js-maximized-container'


# constants for attributes used in a template
templateAttr =
  editable: 'doc-editable'
  container: 'doc-container'
  image: 'doc-image'
  defaultValues:
    editable: 'default'
    container: 'default'
    image: 'image'

templateAttrLookup = {}
for n, v of templateAttr
  templateAttrLookup[v] = n

# constants for attributes used in a document
docAttr =
  # snippet attributes
  template: 'doc-template'

for name, value of templateAttr
  docAttr[name] = value

# prepend attributes with prefix
if config.attributePrefix
  for key, value of docAttr
    docAttr[key] = "#{ config.attributePrefix }-#{ value }"

guid = do ->

  idCounter = lastId = undefined

  # Generate a unique id.
  # Guarantees a unique id in this runtime.
  # Across runtimes its likely but not guaranteed to be unique
  # Use the user prefix to almost guarantee uniqueness,
  # assuming the same user cannot generate snippets in
  # multiple runtimes at the same time (and that clocks are in sync)
  next: (user = 'doc') ->

    # generate 9-digit timestamp
    nextId = Date.now().toString(32)

    # add counter if multiple trees need ids in the same millisecond
    if lastId == nextId
      idCounter += 1
    else
      idCounter = 0
      lastId = nextId

    "#{ user }-#{ nextId }#{ idCounter }"

htmlCompare = do ->

  empty: /^\s*$/
  whitespace: /\s+/g
  normalizeWhitespace: true


  compareElement: (a, b) ->
    if @compareTag(a, b)
      if @compareAttributes(a, b)
        true


  compareTag: (a, b) ->
    @getTag(a) == @getTag(b)


  getTag: (node) ->
    node.namespaceURI + ':' + node.localName


  compareAttributes: (a, b) ->
    if a.attributes.length == b.attributes.length
      for attr in a.attributes
        bValue = b.getAttribute(attr.name)
        return false if not @compareAttributeValue(attr.name, attr.value, bValue)

      return true


  compareAttributeValue: (attrName, aValue, bValue) ->
    return true if not aValue? and not bValue?
    return false if not aValue? or not bValue?

    switch attrName
      when 'class'
        aSorted = aValue.split(' ').sort()
        bSorted = bValue.split(' ').sort()
        aSorted.join(' ') == bSorted.join(' ')
      when 'style'
        aCleaned = @prepareStyleValue(aValue)
        bCleaned = @prepareStyleValue(bValue)
        aCleaned == bCleaned
      else
        aValue == bValue


  prepareStyleValue: (val) ->
    val = $.trim(val)
      .replace(/\s*:\s*/g, ':') # ignore whitespaces around colons
      .replace(/\s*;\s*/g, ';') # ignore whitespaces around semi-colons
      .replace(/;$/g, '') # remove the last semicolon
    val.split(';').sort().join(';')


  # compare two nodes
  # Returns true if they are equivalent.
  # It returns false if either a or b is undefined.
  compareNode: (a, b) ->
    if a? and b?
      if a.nodeType == b.nodeType
        switch a.nodeType
          when 1 then @compareElement(a, b)
          when 3 then @compareText(a, b)
          else log.error "HtmlCompare: nodeType #{ a.nodeType } not supported"


  compareText: (a, b) ->
    if @normalizeWhitespace
      valA = $.trim(a.textContent).replace(@whitespace, ' ')
      valB = $.trim(b.textContent).replace(@whitespace, ' ')
      valA == valB
    else
      a.nodeValue == b.nodeValue


  isEmptyTextNode: (textNode) ->
    @empty.test(textNode.nodeValue) # consider: would .textContent be better?


  compare: (a, b) ->

    # prepare parameters
    a = $(a) if typeof a == 'string'
    b = $(b) if typeof b == 'string'

    a = a[0] if a.jquery
    b = b[0] if b.jquery

    # start comparing
    nextInA = @iterateComparables(a)
    nextInB = @iterateComparables(b)

    equivalent = true
    while equivalent
      equivalent = @compareNode( a = nextInA(), b = nextInB() )

    if not a? and not b? then true else false


  # true if element node or non-empty text node
  isComparable: (node) ->
    nodeType = node.nodeType
    true if nodeType == 1 ||
      ( nodeType == 3 && not @isEmptyTextNode(node) )


  # only iterate over element nodes and non-empty text nodes
  iterateComparables: (root) ->
    iterate = @iterate(root)
    return =>
      while next = iterate()
        return next if @isComparable(next)


  # iterate html nodes
  iterate: (root) ->
    current = next = root

    return ->
      n = current = next
      child = next = undefined
      if current
        if child = n.firstChild
          next = child
        else
          while (n != root) && !(next = n.nextSibling)
            n = n.parentNode

      current

# Fetch the outerHTML of an Element
# ---------------------------------
# @version 1.0.0
# @date February 01, 2011
# @package jquery-sparkle {@link http://www.balupton/projects/jquery-sparkle}
# @author Benjamin Arthur Lupton {@link http://balupton.com}
# @copyright 2011 Benjamin Arthur Lupton {@link http://balupton.com}
# @license MIT License {@link http://creativecommons.org/licenses/MIT/}
# @return {String} outerHtml
jQuery.fn.outerHtml = jQuery.fn.outerHtml || ->
  el = this[0]
  if el
    if (typeof el.outerHTML != 'undefined')
      return el.outerHTML

    try
      # Gecko-based browsers, Safari, Opera.
      (new XMLSerializer()).serializeToString(el)
    catch error
      try
        # Internet Explorer.
        el.xml
      catch error2
        # do nothing


# Switch one class with another
# If the class to be replaced is not present, the class to be added is added anyway
jQuery.fn.replaceClass = (classToBeRemoved, classToBeAdded) ->
  this.removeClass(classToBeRemoved)
  this.addClass(classToBeAdded)


# Include the current node in find
#
# `$("div").findIn(".willBeIncluded")` will include the div as well as the p tag
# in the results:
# ```html
# <div class="willBeIncluded">
#   <p class="willBeIncluded"></p>
# </div>
# ```
jQuery.fn.findIn = (selector) ->
  this.find(selector).add( this.filter(selector) )

# LimitedLocalstore is a wrapper around localstore that
# saves only a limited number of entries and discards
# the oldest ones after that.
#
# You should only ever create one instance by `key`.
# The limit can change between sessions,
# it will just discard all entries until the limit is met
class LimitedLocalstore

  constructor: (@key, @limit) ->
    @limit ||= 10
    @index = undefined


  push: (obj) ->
    reference =
      key: @nextKey()
      date: Date.now()

    index = @getIndex()
    index.push(reference)

    while index.length > @limit
      removeRef = index[0]
      index.splice(0, 1)
      localstore.remove(removeRef.key)

    localstore.set(reference.key, obj)
    localstore.set("#{ @key }--index", index)


  pop: ->
    index = @getIndex()
    if index && index.length
      reference = index.pop()
      value = localstore.get(reference.key)
      localstore.remove(reference.key)
      @setIndex()
      value
    else
      undefined


  get: (num) ->
    index = @getIndex()
    if index && index.length
      num ||= index.length - 1
      reference = index[num]
      value = localstore.get(reference.key)
    else
      undefined


  clear: ->
    index = @getIndex()
    while reference = index.pop()
      localstore.remove(reference.key)

    @setIndex()


  getIndex: ->
    @index ||= localstore.get("#{ @key }--index") || []
    @index


  setIndex: ->
    if @index
      localstore.set("#{ @key }--index", @index)


  nextKey: ->
    # just a random key
    addendum = Math.floor(Math.random() * 1e16).toString(32)
    "#{ @key }-#{ addendum }"







# Access to localstorage
# ----------------------
# wrapper for [https://github.com/marcuswestin/store.js]()
localstore = do ->
  $ = jQuery

  set: (key, value) ->
    store.set(key, value)


  get: (key) ->
    store.get(key)


  remove: (key) ->
    store.remove(key)


  clear: ->
    store.clear()


  disbled: ->
    store.disabled


# Log Helper
# ----------
# Default logging helper
# @params: pass `"trace"` as last parameter to output the call stack
log = (args...) ->
  if window.console?
    if args.length and args[args.length - 1] == 'trace'
      args.pop()
      window.console.trace() if window.console.trace?

    window.console.log.apply(window.console, args)
    undefined


do ->

  # @param level: one of these strings:
  # 'critical', 'error', 'warning', 'info', 'debug'
  notify = (message, level = 'error') ->
    if _rollbar?
      _rollbar.push new Error(message), ->
        if (level == 'critical' or level == 'error') and window.console?.error?
          window.console.error.call(window.console, message)
        else
          log.call(undefined, message)
    else
      if (level == 'critical' or level == 'error')
        throw new Error(message)
      else
        log.call(undefined, message)

    undefined


  log.debug = (message) ->
    notify(message, 'debug')


  log.warn = (message) ->
    notify(message, 'warning')


  # Log error and throw exception
  log.error = (message) ->
    notify(message, 'error')


# Mixin utility
# -------------
# Allow classes to extend from multiple mixins via `extends`.
# Currently this is a simplified version of the [mixin pattern](http://coffeescriptcookbook.com/chapters/classes_and_objects/mixins)
#
# __Usage:__
# `class Superhero extends mixins Flying, SuperAngry, Indestructible`
mixins = (mixins...) ->

  # create an empty function
  Mixed = ->

  # add all objects of the mixins to the prototype of Mixed
  for mixin in mixins by -1 #earlier mixins override later ones
    for name, method of mixin
      Mixed::[name] = method

  Mixed

# Snippet node Iterator
# ---------------------
# Code is ported from rangy NodeIterator and adapted for snippets so it
# does not traverse into containers.
# Use to traverse all element nodes of a snippet but not any appended
# snippets.
class SnippetNodeIterator

  constructor: (root) ->
    @root = @_next = root


  current: null


  hasNext: ->
    !!@_next


  next: () ->
    n = @current = @_next
    child = next = undefined
    if @current
      child = n.firstChild
      if child && n.nodeType == 1 && !n.hasAttribute(docAttr.container)
        @_next = child
      else
        next = null
        while (n != @root) && !(next = n.nextSibling)
          n = n.parentNode

        @_next = next

    @current


  # only iterate over element nodes (Node.ELEMENT_NODE == 1)
  nextElement: () ->
    while @next()
      break if @current.nodeType == 1

    @current


  detach: () ->
    @current = @_next = @root = null


# String Helpers
# --------------
# inspired by [https://github.com/epeli/underscore.string]()
@S = do ->


  # convert 'camelCase' to 'Camel Case'
  humanize: (str) ->
    uncamelized = $.trim(str).replace(/([a-z\d])([A-Z]+)/g, '$1 $2').toLowerCase()
    @titleize( uncamelized )


  # convert the first letter to uppercase
  capitalize : (str) ->
      str = if !str? then '' else String(str)
      return str.charAt(0).toUpperCase() + str.slice(1);


  # convert the first letter of every word to uppercase
  titleize: (str) ->
    if !str?
      ''
    else
      String(str).replace /(?:^|\s)\S/g, (c) ->
        c.toUpperCase()


  # prepend a prefix to a string if it is not already present
  prefix: (prefix, string) ->
    if string.indexOf(prefix) == 0
      string
    else
      "" + prefix + string


  # JSON.stringify with readability in mind
  # @param object: javascript object
  readableJson: (obj) ->
    JSON.stringify(obj, null, 2) # "\t"


  # camelize: (str) ->
  #   $.trim(str).replace(/[-_\s]+(.)?/g, (match, c) ->
  #     c.toUpperCase()

  # dasherize: (str) ->
  #   $.trim(str).replace(/([A-Z])/g, '-$1').replace(/[-_\s]+/g, '-').toLowerCase()

  # classify: (str) ->
  #   $.titleize(String(str).replace(/[\W_]/g, ' ')).replace(/\s/g, '')




class Design

  constructor: (config) ->
    @namespace = config?.namespace || 'livingdocs-templates'
    @css = config.css
    @js = config.js #todo
    @fonts = config.fonts #todo
    @templates = {}


  # either pass an object with many templates as single parameter
  # or the name and template in two parameters
  # e.g add({ [collection] })
  # e.g add('title', '[template]')
  add: (name, template) ->
    if arguments.length == 1
      collection = name
      for name, template of collection
        @add(name, template)

    @templates[name] = new Template
      namespace: @namespace
      name: name
      html: template.html
      title: template.name


  remove: (identifier) ->
    @checkNamespace identifier, (name) =>
      delete @templates[name]


  get: (identifier) ->
    @checkNamespace identifier, (name) =>
      @templates[name]


  checkNamespace: (identifier, callback) ->
    { namespace, name } = Template.parseIdentifier(identifier)

    if not namespace || @namespace == namespace
      callback(name)
    else
      log.error("design #{ @namespace }: cannot get template with different namespace #{ namespace } ")


  each: (callback) ->
    for name, template of @template
      callback(template)

# Document
# --------
# Manage the document and its dependencies.
# Initialze everyting.
#
# ### Design:
# Manage available Templates
#
# ### Assets:
# Load and manage CSS and Javascript dependencies
# of the designs
#
# ### Content:
# Initialize the SnippetTree.
#
# ### Page:
# Initialize event listeners.
# Link the SnippetTree with the DomTree.
document = do ->

  # Private Closure
  # ---------------

  waitingCalls = 1 # 1 -> loadDocument


  documentReady = =>
    waitingCalls -= 1
    if waitingCalls == 0
      document.ready.fire()


  doBeforeDocumentReady = () ->
    waitingCalls += 1
    return documentReady


  # Document object
  # ---------------

  initialized: false
  uniqueId: 0
  ready: $.Callbacks('memory once')
  changed: $.Callbacks()


  # *Public API*
  loadDocument: ({ json, rootNode }={}) ->
    log.error('document is already initialized') if @initialized
    @initialized = true

    @snippetTree = if json && @design
      new SnippetTree(content: json, design: @design)
    else
      new SnippetTree()

    # forward changed event
    @snippetTree.changed.add =>
      @changed.fire()

    # Page initialization
    @page = new Page()

    # load design assets into page
    if @design.css
      @page.loader.css(@design.css, doBeforeDocumentReady())

    # render document
    rootNode ||= @page.getDocumentSection()[0]
    @renderer = new Renderer(snippetTree: @snippetTree, rootNode: rootNode, page: @page)

    @ready.add =>
      @renderer.render()

    documentReady()


  addDesign: (snippetCollection, config) ->
    @design = new Design(config)
    @design.add(snippetCollection)


  eachContainer: (callback) ->
    @snippetTree.eachContainer(callback)


  # list available Templates
  listTemplates: ->
    templates = []
    @design.each (template) ->
      templates.push(template.identifier)

    templates


  # *Public API*
  add: (input) ->
    if jQuery.type(input) == 'string'
      snippet = @createSnippet(input)
    else
      snippet = input

    @snippetTree.append(snippet) if snippet
    snippet


  # *Public API*
  createSnippet: (identifier) ->
    template = @getTemplate(identifier)
    template.createSnippet() if template


  # find all instances of a certain Template
  # e.g. search "bootstrap.hero" or just "hero"
  find: (search) ->
    @snippetTree.find(search)


  # print documentation for a snippet template
  help: (identifier) ->
    template = @getTemplate(identifier)
    template.printDoc()


  # print the SnippetTree
  printTree: () ->
    @snippetTree.print()


  # consider: use guids so transferring snippets between documents
  # can not cause id conflicts
  nextId: (prefix = 'doc') ->

    @uniqueId += 1
    "#{ prefix }-#{ @uniqueId }"


  toJson: ->
    json = @snippetTree.toJson()
    json['meta'] =
      title: undefined
      author: undefined
      created: undefined
      published: undefined

    json


  restore: (contentJson, resetFirst = true) ->
    @reset() if resetFirst
    @snippetTree.fromJson(contentJson, @design)
    @renderer.render()


  reset: ->
    @renderer.clear()
    @snippetTree.detach()


  getTemplate: (identifier) ->
    template = @design?.get(identifier)

    if !template
      log.error("could not find template #{ identifier }")

    template


# DOM helper methods
# ------------------
# Methods to parse and update the Dom tree in accordance to
# the SnippetTree and Livingdocs classes and attributes
dom = do ->
  snippetRegex = new RegExp("(?: |^)#{ docClass.snippet }(?: |$)")
  sectionRegex = new RegExp("(?: |^)#{ docClass.section }(?: |$)")

  # Find the snippet this node is contained within.
  # Snippets are marked by a class at the moment.
  parentSnippetElem: (node) ->
    node = @getElementNode(node)

    while node && node.nodeType == 1 # Node.ELEMENT_NODE == 1
      if snippetRegex.test(node.className)
        snippetElem = @getSnippetElem(node)
        return snippetElem

      node = node.parentNode

    return undefined


  parentSnippet: (node) ->
    @parentSnippetElem(node)?.snippet


  parentContainer: (node) ->
    node = @getElementNode(node)

    while node && node.nodeType == 1 # Node.ELEMENT_NODE == 1
      if node.hasAttribute(docAttr.container)
        containerName = node.getAttribute(docAttr.container)
        if not sectionRegex.test(node.className)
          snippetElem = @parentSnippetElem(node)

        return {
          node: node
          containerName: containerName
          snippetElem: snippetElem
        }

      node = node.parentNode

    {}


  dropTarget: (node, { top, left }) ->
    node = @getElementNode(node)

    while node && node.nodeType == 1 # Node.ELEMENT_NODE == 1
      if node.hasAttribute(docAttr.container)
        containerName = node.getAttribute(docAttr.container)
        if not sectionRegex.test(node.className)
          insertSnippet = @getPositionInContainer($(node), { top, left })
          if insertSnippet
            coords = @getInsertPosition(insertSnippet.$elem[0], insertSnippet.position)
            return { snippetElem: insertSnippet.snippetElem, position: insertSnippet.position, coords }
          else
            snippetElem = @parentSnippetElem(node)
            return { containerName: containerName, parent: snippetElem, node: node }

      else if snippetRegex.test(node.className)
        pos = @getPositionInSnippet($(node), { top, left })
        snippetElem = @getSnippetElem(node)
        coords = @getInsertPosition(node, pos.position)
        return { snippetElem: snippetElem, position: pos.position, coords }

      else if sectionRegex.test(node.className)
        return { root: true }

      node = node.parentNode

    {}


  getInsertPosition: (elem, position) ->
    rect = @getBoundingClientRect(elem)
    if position == 'before'
      { top: rect.top, left: rect.left, width: rect.width }
    else
      { top: rect.bottom, left: rect.left, width: rect.width }


  # figure out if we should insert before or after snippet
  # based on the cursor position
  getPositionInSnippet: ($elem, { top, left }) ->
    elemTop = $elem.offset().top
    elemHeight = $elem.outerHeight()
    elemBottom = elemTop + elemHeight

    if @distance(top, elemTop) < @distance(top, elemBottom)
      { position: 'before' }
    else
      { position: 'after' }


  # figure out if the user wanted to insert between snippets
  # instead of appending to the container
  # (this can be the case if the drop occurs on a margin)
  getPositionInContainer: ($container, { top, left }) ->
    $snippets = $container.find(".#{ docClass.snippet }")
    closest = undefined
    insertSnippet = undefined

    $snippets.each (index, elem) =>
      $elem = $(elem)
      elemTop = $elem.offset().top
      elemHeight = $elem.outerHeight()
      elemBottom = elemTop + elemHeight

      if not closest or @distance(top, elemTop) < closest
        closest = @distance(top, elemTop)
        insertSnippet = { $elem, position: 'before'}
      if not closest or @distance(top, elemBottom) < closest
        closest = @distance(top, elemBottom)
        insertSnippet = { $elem, position: 'after'}

      if insertSnippet
        insertSnippet.snippetElem = @getSnippetElem(insertSnippet.$elem[0])

    insertSnippet


  distance: (a, b) ->
    if a > b then a-b else b-a


  # force all containers of a snippet to be as high as they can be
  # sets css style height
  maximizeContainerHeight: (snippetElem) ->
    if snippetElem.template.containerCount > 1
      for name, elem of snippetElem.containers
        $elem = $(elem)
        continue if $elem.hasClass(docClass.maximizedContainer)
        $parent = $elem.parent()
        parentHeight = $parent.height()
        outer = $elem.outerHeight(true) - $elem.height()
        $elem.height(parentHeight - outer)
        $elem.addClass(docClass.maximizedContainer)


  # remove all css style height declarations added by
  # maximizeContainerHeight()
  restoreContainerHeight: () ->
    $(".#{ docClass.maximizedContainer }")
      .css('height', '')
      .removeClass(docClass.maximizedContainer)


  getElementNode: (node) ->
    if node?.jquery
      node[0]
    else if node?.nodeType == 3 # Node.TEXT_NODE == 3
      node.parentNode
    else
      node


  # Snippets store a reference of themselves in their Dom node
  # consider: store reference directly without jQuery
  getSnippetElem: (node) ->
    $(node).data('snippet')


  getBoundingClientRect: (node) ->
    coords = node.getBoundingClientRect()

    # code from mdn: https://developer.mozilla.org/en-US/docs/Web/API/window.scrollX
    scrollX = if (window.pageXOffset != undefined) then window.pageXOffset else (document.documentElement || window.document.body.parentNode || window.document.body).scrollLeft
    scrollY = if (window.pageYOffset != undefined) then window.pageYOffset else (document.documentElement || window.document.body.parentNode || window.document.body).scrollTop

    # translate into absolute positions
    coords =
      top: coords.top + scrollY
      bottom: coords.bottom + scrollY
      left: coords.left + scrollX
      right: coords.right + scrollX

    coords.height = coords.bottom - coords.top
    coords.width = coords.right - coords.left

    coords



# DragDrop
#
# to start a drag operation:
# aDragdropInstance.mousedown(...)
#
# options that can be set when creating an instance or overwritten for every drag (applicable in mousedown call)
# @option direct: if true the specified element itself is moved while dragging, otherwise a semi-transparent clone is created
#
# long press:
# @option longpressDelay: miliseconds that the mouse needs to be pressed before drag initiates
# @option longpressDistanceLimit: if the pointer is moved by more pixels during the longpressDelay the drag operation is aborted
#
# click friendly:
# @option minDistance: drag is initialized only if the pointer is moved by a minimal distance
# @option preventDefault: call preventDefault on mousedown (prevents browser drag & drop)
#
# options for a single drag (pass directly to mousedown call)
# @option drag.fixed: set to true for position: fixed elements
# @option drag.mouseToSnippet: e.g. { left: 20, top: 20 }, force position of dragged element relative to cursor
# @option drag.width: e.g. 300, force width of dragged element
# @option drag.onDrop: callback( dragObj, $origin ), will be called after the node is dropped
# @option drag.onDrag: callback( tragTarget, dragObj ), will be called after the node is dropped
# @option drag.onDragStart: callback( dragObj ), will be called after the drag started

class DragDrop

  constructor: (options) ->

    @defaultOptions = $.extend({
        longpressDelay: 0
        longpressDistanceLimit: 10
        minDistance: 0
        direct: false
        preventDefault: true
        createPlaceholder: DragDrop.placeholder
      }, options)

    # per drag properties
    @drag = {}

    @$origin = undefined
    @$dragged = undefined


  # start a possible drag
  # the drag is only really started if constraints are not violated (longpressDelay and longpressDistanceLimit or minDistance)
  mousedown: ($origin, event, options = {}) ->
    @reset()
    @drag.initialized = true
    @options = $.extend({}, @defaultOptions, options)
    @drag.startPoint = { left: event.pageX, top: event.pageY }
    @$origin = $origin

    if @options.longpressDelay and @options.longpressDistanceLimit
      @drag.timeout = setTimeout( =>
        @start()
      , @options.longpressDelay)

    # prevent browser Drag & Drop
    event.preventDefault() if @options.preventDefault


  # start the drag process
  start: ->
    @drag.started = true

    mouseLeft = @drag.startPoint.left
    mouseTop = @drag.startPoint.top

    if typeof @options.onDragStart == 'function'
        @options.onDragStart.call(this, @drag, { left: mouseLeft, top: mouseTop })

    # prevent text-selections while dragging
    $(window.document.body).addClass(docClass.preventSelection)

    if @options.direct
      @$dragged = @$origin
    else
      @$dragged = @options.createPlaceholder(@drag, @$origin)

    if @drag.fixed
      @drag.$body = $(window.document.body)

    # positionDragged
    @move(mouseLeft, mouseTop)

    if !@direct
      @$dragged.appendTo(window.document.body).show()
      @$origin?.addClass(docClass.dragged)


  move: (mouseLeft, mouseTop, event) ->
    if @drag.started
      if @drag.mouseToSnippet
        left = mouseLeft - @drag.mouseToSnippet.left
        top = mouseTop - @drag.mouseToSnippet.top
      else
        left = mouseLeft
        top = mouseTop

      if @drag.fixed
        top = top - @drag.$body.scrollTop()
        left = left - @drag.$body.scrollLeft()

      left = 2 if left < 2
      top = 2 if top < 2

      @$dragged.css({ position:'absolute', left:"#{ left }px", top:"#{ top }px" })
      @dropTarget(mouseLeft, mouseTop, event) if !@direct

    else if @drag.initialized

      # long press measurement of mouse movement prior to drag initialization
      if @options.longpressDelay and @options.longpressDistanceLimit
        @reset() if @distance({ left: mouseLeft, top: mouseTop }, @drag.startPoint) > @options.longpressDistanceLimit

      # delayed initialization after mouse moved a minimal distance
      if @options.minDistance && @distance({ left: mouseLeft, top: mouseTop }, @drag.startPoint) > @options.minDistance
        @start()


  drop: () ->
    if @drag.started

      # drag specific callback
      if typeof @options.onDrop == 'function'
        @options.onDrop.call(this, @drag, @$origin)

    @reset()


  dropTarget: (mouseLeft, mouseTop, event) ->
    if @$dragged && event
      elem = undefined

      # get the element we're currently hovering
      if event.clientX && event.clientY
        @$dragged.hide()
        # todo: Safari 4 and Opera 10.10 need pageX/Y.
        elem = window.document.elementFromPoint(event.clientX, event.clientY)
        @$dragged.show()

      # check if a drop is possible
      if elem
        dragTarget = dom.dropTarget(elem, { top: mouseTop, left: mouseLeft })
        @drag.target = dragTarget
      else
        @drag.target = {}

      if typeof @options.onDrag == 'function'
        @options.onDrag.call(this, @drag.target, @drag, { left: mouseLeft, top: mouseTop })


  distance: (pointA, pointB) ->
    return undefined if !pointA || !pointB

    distX = pointA.left - pointB.left
    distY = pointA.top - pointB.top
    Math.sqrt( (distX * distX) + (distY * distY) )


  reset: ->
    if @drag.initialized
      clearTimeout(@drag.timeout) if @drag.timeout
      @drag.preview.remove() if @drag.preview

      if @$dragged and @$dragged != @$origin
        @$dragged.remove()

      if @$origin
        @$origin.removeClass(docClass.dragged)
        @$origin.show()

      $(window.document.body).removeClass(docClass.preventSelection)

      @drag = {}
      @$origin = undefined
      @$dragged = undefined


# Drag preview method -> these are set in the configuration and can be replaced
DragDrop.cloneOrigin = (drag, $origin) ->

  # calculate mouse position relative to snippet
  if !drag.mouseToSnippet
    snippetOffset = $origin.offset()
    marginTop = parseFloat( $origin.css("margin-top") )
    marginLeft = parseFloat( $origin.css("margin-left") )
    drag.mouseToSnippet =
      left: (mouseLeft - snippetOffset.left + marginLeft)
      top: (mouseTop - snippetOffset.top + marginTop)

  # clone snippet
  snippetWidth = drag.width || $origin.width()
  draggedCopy = $origin.clone()

  draggedCopy.css({ position: "absolute", width: snippetWidth })
    .removeClass(docClass.snippetHighlight)
    .addClass(docClass.draggedPlaceholder)

  # set white background on transparent elements
  backgroundColor = $origin.css("background-color")
  hasBackgroundColor = backgroundColor != "transparent" && backgroundColor != "rgba(0, 0, 0, 0)"
  # backgroundSetting = @$origin.css("background") || @$origin.css("background-color")

  if !hasBackgroundColor
    draggedCopy.css({ "background-color": "#fff"})

  return draggedCopy


DragDrop.placeholder = (drag) ->
  snippetWidth = drag.width
  numberOfDraggedElems = 1
  if !drag.mouseToSnippet
    drag.mouseToSnippet =
      left: 2
      top: -15

  template =
    """
    <div class="doc-drag-placeholder-item">
      <span class="doc-drag-counter">#{ numberOfDraggedElems }</span>
      Selected Item
    </div>
    """

  $placeholder = $(template)
  $placeholder.css(width: snippetWidth) if snippetWidth
  $placeholder.css(position: "absolute")




# EditableJS Controller
# ---------------------
# Integrate EditableJS into Livingdocs
class EditableController


  constructor: (@page) ->

    # configure editableJS
    Editable.init
      log: false

    @selection = $.Callbacks()

    Editable
      .focus($.proxy(@focus, @))
      .blur($.proxy(@blur, @))
      .selection($.proxy(@selectionChanged, @))


  add: (nodes) ->
    Editable.add(nodes)


  focus: (element) ->
    snippet = dom.parentSnippet(element)
    @page.focus.editableFocused(element, snippet)


  blur: (element) ->
    snippet = dom.parentSnippet(element)
    @page.focus.editableBlurred(element, snippet)
    editableName = element.getAttribute(docAttr.editable)
    snippet.set(editableName, element.innerHTML)


  selectionChanged: (element, selection) ->
    snippet = dom.parentSnippet(element)
    @selection.fire(snippet, element, selection)


# Document Focus
# --------------
# Manage the snippet or editable that is currently focused
class Focus

  constructor: ->
    @editableNode = undefined
    @snippet = undefined

    @snippetFocus = $.Callbacks()
    @snippetBlur = $.Callbacks()


  setFocus: (snippet, editableNode) ->
    if editableNode != @editableNode
      @blurEditable()
      @editableNode = editableNode

    if snippet != @snippet
      @blurSnippet()

      @snippet = snippet
      @snippetFocus.fire(@snippet)


  # call after browser focus change
  editableFocused: (editableNode, snippet) ->
    if @editableNode != editableNode
      snippet ||= dom.parentSnippet(editableNode)
      @setFocus(snippet, editableNode)


  # call after browser focus change
  editableBlurred: (editableNode, snippet) ->
    if @editableNode == editableNode
      @setFocus(@snippet, undefined)


  # call after click
  snippetFocused: (snippet) ->
    if @snippet != snippet
      @setFocus(snippet, undefined)


  blur: ->
    @setFocus(undefined, undefined)


  # Private
  # -------

  # @api private
  blurEditable: ->
    if @editableNode
      @editableNode = undefined


  # @api private
  blurSnippet: ->
    if @snippet
      previous = @snippet
      @snippet = undefined
      @snippetBlur.fire(previous)



# History
# -------
# Represents the performed actions in a document
class History

  history: []

  constructor: () ->
    #todo


  # add an action to the history
  add: () ->
    #todo


  # track the saved state
  saved: () ->
    #todo


  # The history is dirty if there are unsaved actions in the history
  isDirty: () ->
    return false if history.length == 0



class HistoryAction

  constructor: () ->
    #todo

class InterfaceInjector

  constructor: ({ @snippet, @snippetContainer, @renderer }) ->

    if @snippet && not @snippet.snippetElem?.attachedToDom
      log.error('snippet is not attached to the DOM')

    if @snippetContainer
      if not @snippetContainer.isRoot && not @snippetContainer.parentSnippet?.snippetElem?.attachedToDom
        log.error('snippetContainer is not attached to the DOM')


  before: ($elem) ->
    if @snippet
      @beforeInjecting($elem)
      @snippet.snippetElem.$html.before($elem)
    else
      log.error('cannot use before on a snippetContainer')


  after: ($elem) ->
    if @snippet
      @beforeInjecting($elem)
      @snippet.snippetElem.$html.after($elem)
    else
      log.error('cannot use after on a snippetContainer')


  append: ($elem) ->
    if @snippetContainer
      @beforeInjecting($elem)
      @renderer.appendToContainer(@snippetContainer, $elem)
    else
      log.error('cannot use append on a snippet')


  remove: () ->
    for $elem in @injected
      $elem.remove()

    @injected = undefined


  beforeInjecting: ($elem) ->
    @injected ||= []
    @injected.push($elem)
    $elem.addClass(docClass.interface)

# Script Loader
# -------------
# Loading of Javascript and CSS files using yepnope
class Loader

  constructor: ->
    @loadedCssFiles = []


  replaceCss: (cssUrl, callback) ->
    @removeCss()
    @css(cssUrl, callback)


  # laod css files
  # @param cssUrl: can be either a string or an array
  # @param callback: callback when all scripts are loaded
  css: (cssUrl, callback) ->
    cssUrl = [cssUrl] if !$.isArray(cssUrl)

    # add `css!` prefix to urls so yepnope always treats them as css files
    cssUrl = for url in cssUrl
      @loadedCssFiles.push(url)
      S.prefix('css!', url)

    # yepnope calls the callback for each file to load
    # but we want to execute the callback only once all files are loaded
    filesToLoad = cssUrl.length

    yepnope
      load: cssUrl
      callback: () ->
        filesToLoad -= 1
        callback() if callback && filesToLoad <= 0 # < is for the case where the array is empty


  # @param cssUrl: string or array. if not passed all loaded css files
  # will be unloaded
  removeCss: (cssUrl) ->
    cssUrl = [cssUrl] if cssUrl? && !$.isArray(cssUrl)
    cssUrl =  cssUrl || @loadedCssFiles

    for url in cssUrl
      $("link[rel=stylesheet][href~='#{ url }']").remove()

    @loadedCssFiles = []

# page
# ----
# Defines the API between the DOM and the document
class Page


  constructor: ->
    @$document = $(window.document)
    @$body = $(window.document.body)

    @loader = new Loader()
    @focus = new Focus()
    @editableController = new EditableController(this)

    @snippetDragDrop = new DragDrop
      longpressDelay: 400
      longpressDistanceLimit: 10
      preventDefault: false

    @$document
      .on('click.livingdocs', $.proxy(@click, @))
      .on('mousedown.livingdocs', $.proxy(@mousedown, @))
      .on('dragstart', $.proxy(@browserDragStart, @))


  # prevent the browser Drag&Drop from interfering
  browserDragStart: (event) ->
    event.preventDefault()
    event.stopPropagation()


  removeListeners: ->
    @$document.off('.livingdocs')
    @$document.off('.livingdocs-drag')


  # @param rootNode (optional) DOM node that should contain the content
  # @return jQuery object: the root node of the document
  getDocumentSection: ({ rootNode } = {}) ->
    if !rootNode
      $root = $(".#{ docClass.section }").first()
    else
      $root = $(rootNode).addClass(".#{ docClass.section }")

    log.error('no rootNode found') if !$root.length
    $root


  mousedown: (event) ->
    return if event.which != 1 # only respond to left mouse button
    snippetElem = dom.parentSnippetElem(event.target)

    if snippetElem
      @startDrag(snippetElem: snippetElem, dragDrop: @snippetDragDrop)


  startDrag: ({ snippet, snippetElem, dragDrop }) ->
    return unless snippet || snippetElem
    snippet = snippetElem.snippet if snippetElem

    @$document.on 'mousemove.livingdocs-drag', (event) ->
      dragDrop.move(event.pageX, event.pageY, event)

    @$document.on 'mouseup.livingdocs-drag', =>
      dragDrop.drop()
      @$document.off('.livingdocs-drag')

    snippetDrag = new SnippetDrag({ snippet: snippet, page: this })

    $snippet = snippetElem.$html if snippetElem
    dragDrop.mousedown $snippet, event,
      onDragStart: snippetDrag.onStart
      onDrag: snippetDrag.onDrag
      onDrop: snippetDrag.onDrop


  click: (event) ->
    snippet = dom.parentSnippet(event.target)

    # todo: if a user clicked on a margin of a snippet it should
    # still get selected. (if a snippet is found by parentSnippet
    # and that snippet has no children we do not need to search)

    # if snippet hasChildren, make sure we didn't want to select
    # a child

    # if no snippet was selected check if the user was not clicking
    # on a margin of a snippet

    # todo: check if the click was meant for a snippet container
    if snippet
      @focus.snippetFocused(snippet)
    else
      @focus.blur()


  getFocusedElement: ->
    window.document.activeElement


  blurFocusedElement: ->
    @focus.setFocus(undefined)
    focusedElement = @getFocusedElement()
    $(focusedElement).blur() if focusedElement


class Renderer


  constructor: ({ @snippetTree, rootNode, @page }) ->
    log.error('no snippet tree specified') if !@snippetTree
    log.error('no root node specified') if !rootNode

    @$root = $(rootNode)
    @setupPageListeners()
    @setupSnippetTreeListeners()
    @snippets = {}

    # focus

  # Snippet Tree Event Handling
  # ---------------------------

  setupPageListeners: ->
    @page.focus.snippetFocus.add( $.proxy(this, 'highlightSnippet') )
    @page.focus.snippetBlur.add( $.proxy(this, 'removeSnippetHighlight') )


  setupSnippetTreeListeners: ->
    @snippetTree.snippetAdded.add( $.proxy(this, 'snippetAdded') )
    @snippetTree.snippetRemoved.add( $.proxy(this, 'snippetRemoved') )
    @snippetTree.snippetMoved.add( $.proxy(this, 'snippetMoved') )
    @snippetTree.snippetContentChanged.add( $.proxy(this, 'snippetContentChanged') )


  snippetAdded: (snippet) ->
    snippetElem = @ensureSnippetElem(snippet)
    @updateDomPosition(snippetElem)


  snippetRemoved: (snippet) ->
    if snippetElem = @getSnippetElem(snippet)
      if snippetElem.attachedToDom
        @detachFromDom(snippetElem)
        delete @snippets[snippet.id]


  snippetMoved: (snippet) ->
    snippetElem = @ensureSnippetElem(snippet)
    @updateDomPosition(snippetElem)


  snippetContentChanged: (snippet) ->
    snippetElem = @ensureSnippetElem(snippet)
    @insertIntoDom(snippetElem) if not snippetElem.attachedToDom
    snippetElem.updateContent()


  # Rendering
  # ---------

  getSnippetElem: (snippet) ->
    @snippets[snippet.id] if snippet


  ensureSnippetElem: (snippet) ->
    return unless snippet
    @snippets[snippet.id] || @createSnippetElem(snippet)


  # creates a snippetElem instance for this snippet
  # @api: private
  createSnippetElem: (snippet) ->
    snippetElem = snippet.template.createHtml(snippet)
    @snippets[snippet.id] = snippetElem


  render: ->
    @$root.empty()

    @snippetTree.each (snippet) =>
      snippetElem = @ensureSnippetElem(snippet)
      @insertIntoDom(snippetElem)


  clear: ->
    @snippetTree.each (snippet) ->
      snippetElem = @getSnippetElem(snippet)
      snippetElem?.attachedToDom = false

    @$root.empty()


  redraw: ->
    @clear()
    @render()


  updateDomPosition: (snippetElem) ->
    @detachFromDom(snippetElem) if snippetElem.attachedToDom
    @insertIntoDom(snippetElem)


  # insert the snippet into the Dom according to its position
  # in the SnippetTree
  insertIntoDom: (snippetElem) ->
    snippetElem.attach(this)
    log.error('could not insert snippet into Dom') if not snippetElem.attachedToDom
    @afterDomInsert(snippetElem)

    this


  afterDomInsert: (snippetElem) ->
    # initialize editables
    editableNodes = for name, node of snippetElem.editables
      node

    @page.editableController.add(editableNodes)


  detachFromDom: (snippetElem) ->
    snippetElem.detach()
    this


  # Highlight methods
  # -----------------

  highlightSnippet: (snippet) ->
    if snippetElem = @getSnippetElem(snippet)
      snippetElem.$html.addClass(docClass.snippetHighlight)


  removeSnippetHighlight: (snippet) ->
    if snippetElem = @getSnippetElem(snippet)
      snippetElem.$html.removeClass(docClass.snippetHighlight)


  # UI Inserts
  # ----------

  createInterfaceInjector: (snippetOrContainer) ->
    if snippetOrContainer instanceof Snippet
      @createSnippetInterfaceInjector(snippetOrContainer)
    else if snippetOrContainer instanceof SnippetContainer
      @createSnippetContainerInterfaceInjector(snippetOrContainer)


  createSnippetInterfaceInjector: (snippet) ->
    if snippet.uiInjector == undefined
      snippet.uiInjector = new InterfaceInjector
        snippet: snippet
        renderer: this


  createSnippetContainerInterfaceInjector: (snippetContainer) ->
    if snippetContainer.uiInjector == undefined
      snippetContainer.uiInjector = new InterfaceInjector
        snippetContainer: snippetContainer
        renderer: this



# Snippet
# -------
# Snippets are more or less the equivalent to nodes in the DOM tree.
# Each snippet has a Template which allows to generate HTML
# from a snippet or generate a snippet instance from HTML.
#
# Represents a node in a SnippetTree.
# Every snippet can have a parent (SnippetContainer),
# siblings (other snippets) and multiple containers (SnippetContainers).
#
# The containers are the parents of the child Snippets.
# E.g. a grid row would have as many containers as it has
# columns
#
# # @prop parentContainer: parent SnippetContainer
class Snippet


  constructor: ({ @template, id } = {}) ->
    if !@template
      log.error('cannot instantiate snippet without template reference')

    @initializeContainers()
    @initializeEditables()
    @initializeImages()

    @id = id || guid.next()
    @identifier = @template.identifier

    @next = undefined # set by SnippetContainer
    @previous = undefined # set by SnippetContainer
    @snippetTree = undefined # set by SnippetTree


  initializeContainers: ->
    @containerCount = @template.directives.count.container
    for containerName of @template.directives.container
      @containers ||= {}
      @containers[containerName] = new SnippetContainer
        name: containerName
        parentSnippet: this


  initializeEditables: ->
    @editableCount = @template.directives.count.editable
    for editableName of @template.directives.editable
      @editables ||= {}
      @editables[editableName] = undefined


  initializeImages: ->
    @imageCount = @template.directives.count.image
    for imageName of @template.directives.image
      @images ||= {}
      @images[imageName] = undefined


  hasImages: ->
    @imageCount > 0


  hasContainers: ->
    @containers?


  before: (snippet) ->
    if snippet
      @parentContainer.insertBefore(this, snippet)
      this
    else
      @previous


  after: (snippet) ->
    if snippet
      @parentContainer.insertAfter(this, snippet)
      this
    else
      @next


  append: (containerName, snippet) ->
    if arguments.length == 1
      snippet = containerName
      containerName = templateAttr.defaultValues.container

    @containers[containerName].append(snippet)
    this


  prepend: (containerName, snippet) ->
    if arguments.length == 1
      snippet = containerName
      containerName = templateAttr.defaultValues.container

    @containers[containerName].prepend(snippet)
    this


  set: (name, value) ->
    if @editables?.hasOwnProperty(name)
      if @editables[name] != value
        @editables[name] = value
        @snippetTree.contentChanging(this) if @snippetTree
    else if @images?.hasOwnProperty(name)
      if @images[name] != value
        @images[name] = value
        @snippetTree.contentChanging(this) if @snippetTree
    else
      log.error("set error: #{ @identifier } has no content named #{ name }")


  get: (name) ->
    if @editables?.hasOwnProperty(name)
      @editables[name]
    else if @images?.hasOwnProperty(name)
      @images[name]
    else
      log.error("get error: #{ @identifier } has no name named #{ name }")


  hasEditables: ->
    @editables?


  # move up (previous)
  up: ->
    @parentContainer.up(this)
    this


  # move down (next)
  down: ->
    @parentContainer.down(this)
    this


  # remove TreeNode from its container and SnippetTree
  remove: ->
    @parentContainer.remove(this)


  # @api private
  destroy: ->
    # todo: move into to renderer

    # remove user interface elements
    @uiInjector.remove() if @uiInjector


  getParent: ->
     @parentContainer?.parentSnippet


  ui: ->
    if not @uiInjector
      @snippetTree.renderer.createInterfaceInjector(this)
    @uiInjector


  # Iterators
  # ---------

  parents: (callback) ->
    snippet = this
    while (snippet = snippet.getParent())
      callback(snippet)


  children: (callback) ->
    for name, snippetContainer of @containers
      snippet = snippetContainer.first
      while (snippet)
        callback(snippet)
        snippet = snippet.next


  descendants: (callback) ->
    for name, snippetContainer of @containers
      snippet = snippetContainer.first
      while (snippet)
        callback(snippet)
        snippet.descendants(callback)
        snippet = snippet.next


  descendantsAndSelf: (callback) ->
    callback(this)
    @descendants(callback)


  # return all descendant containers (including those of this snippet)
  descendantContainers: (callback) ->
    @descendantsAndSelf (snippet) ->
      for name, snippetContainer of snippet.containers
        callback(snippetContainer)


  # return all descendant containers and snippets
  allDescendants: (callback) ->
    @descendantsAndSelf (snippet) =>
      callback(snippet) if snippet != this
      for name, snippetContainer of snippet.containers
        callback(snippetContainer)


  childrenAndSelf: (callback) ->
    callback(this)
    @children(callback)


  # Serialization
  # -------------

  toJson: ->

    json =
      id: @id
      identifier: @identifier

    if @hasEditables()
      json.editables = {}
      for name, value of @editables
        json.editables[name] = value

    for name of @images
      json.images ||= {}
      for name, value of @images
        json.images[name] = value

    for name of @containers
      json.containers ||= {}
      json.containers[name] = []

    json


Snippet.fromJson = (json, design) ->
  template = design.get(json.identifier)

  if not template?
    log.error("error while deserializing snippet: unknown template identifier '#{ json.identifier }'")

  snippet = new Snippet({ template, id: json.id })
  for editableName, value of json.editables
    if snippet.editables.hasOwnProperty(editableName)
      snippet.editables[editableName] = value
    else
      log.error("error while deserializing snippet: unknown editable #{ editableName }")

  for imageName, value of json.images
    if snippet.images.hasOwnProperty(imageName)
      snippet.images[imageName] = value
    else
      log.error("error while deserializing snippet: unknown image #{ imageName }")

  for containerName, snippetArray of json.containers
    if not snippet.containers.hasOwnProperty(containerName)
      log.error("error while deserializing snippet: unknown container #{ containerName }")

    if snippetArray

      if not $.isArray(snippetArray)
        log.error("error while deserializing snippet: container is not array #{ containerName }")

      for child in snippetArray
        snippet.append( containerName, Snippet.fromJson(child, design) )

  snippet

# jQuery like results when searching for snippets.
# `doc("hero")` will return a SnippetArray that works similar to a jQuery object.
# For extensibility via plugins we expose the prototype of SnippetArray via `doc.fn`.
class SnippetArray


  # @param snippets: array of snippets
  constructor: (@snippets) ->
    @snippets = [] unless @snippets?
    @createPseudoArray()


  createPseudoArray: () ->
    for result, index in @snippets
      @[index] = result

    @length = @snippets.length
    if @snippets.length
      @first = @[0]
      @last = @[@snippets.length - 1]


  each: (callback) ->
    for snippet in @snippets
      callback(snippet)

    this


  remove: () ->
    @each (snippet) ->
      snippet.remove()

    this

# SnippetContainer
# ----------------
# A SnippetContainer contains and manages a linked list
# of snippets.
#
# The snippetContainer is responsible for keeping its snippetTree
# informed about changes (only if they are attached to one).
# 
# @prop first: first snippet in the container
# @prop last: last snippet in the container
# @prop parentSnippet: parent Snippet
class SnippetContainer


  constructor: ({ @parentSnippet, @name, isRoot }) ->
    @isRoot = isRoot?
    @first = @last = undefined


  prepend: (snippet) ->
    if @first
      @insertBefore(@first, snippet)
    else
      @attachSnippet(snippet)

    this


  append: (snippet) ->
    if @parentSnippet? and snippet == @parentSnippet
      log.error('cannot append snippet to itself')

    if @last
      @insertAfter(@last, snippet)
    else
      @attachSnippet(snippet)

    this


  insertBefore: (snippet, insertedSnippet) ->
    return if snippet.previous == insertedSnippet
    log.error('cannot insert snippet before itself') if snippet == insertedSnippet

    position =
      previous: snippet.previous
      next: snippet
      parentContainer: snippet.parentContainer

    @attachSnippet(insertedSnippet, position)


  insertAfter: (snippet, insertedSnippet) ->
    return if snippet.next == insertedSnippet
    log.error('cannot insert snippet after itself') if snippet == insertedSnippet

    position =
      previous: snippet
      next: snippet.next
      parentContainer: snippet.parentContainer

    @attachSnippet(insertedSnippet, position)


  up: (snippet) ->
    if snippet.previous?
      @insertBefore(snippet.previous, snippet)


  down: (snippet) ->
    if snippet.next?
      @insertAfter(snippet.next, snippet)


  getSnippetTree: ->
    @snippetTree || @parentSnippet?.snippetTree


  # Traverse all snippets
  each: (callback) ->
    snippet = @first
    while (snippet)
      snippet.descendantsAndSelf(callback)
      snippet = snippet.next


  eachContainer: (callback) ->
    callback(this)
    @each (snippet) ->
      for name, snippetContainer of snippet.containers
        callback(snippetContainer)


  # Traverse all snippets and containers
  all: (callback) ->
    callback(this)
    @each (snippet) ->
      callback(snippet)
      for name, snippetContainer of snippet.containers
        callback(snippetContainer)


  remove: (snippet) ->
    snippet.destroy()
    @_detachSnippet(snippet)


  ui: ->
    if not @uiInjector
      snippetTree = @getSnippetTree()
      snippetTree.renderer.createInterfaceInjector(this)
    @uiInjector


  # Private
  # -------

  # Every snippet added or moved most come through here.
  # Notifies the snippetTree if the parent snippet is
  # attached to one.
  # @api private
  attachSnippet: (snippet, position = {}) ->
    func = =>
      @link(snippet, position)

    if snippetTree = @getSnippetTree()
      snippetTree.attachingSnippet(snippet, func)
    else
      func()


  # Every snippet that is removed must come through here.
  # Notifies the snippetTree if the parent snippet is
  # attached to one.
  # Snippets that are moved inside a snippetTree should not
  # call _detachSnippet since we don't want to raise
  # SnippetRemoved events on the snippet tree, in these
  # cases unlink can be used
  # @api private
  _detachSnippet: (snippet) ->
    func = =>
      @unlink(snippet)

    if snippetTree = @getSnippetTree()
      snippetTree.detachingSnippet(snippet, func)
    else
      func()


  # @api private
  link: (snippet, position) ->
    @unlink(snippet) if snippet.parentContainer

    position.parentContainer ||= this
    @setSnippetPosition(snippet, position)


  # @api private
  unlink: (snippet) ->
    container = snippet.parentContainer
    if container

      # update parentContainer links
      container.first = snippet.next unless snippet.previous?
      container.last = snippet.previous unless snippet.next?

      # update previous and next nodes
      snippet.next?.previous = snippet.previous
      snippet.previous?.next = snippet.next

      @setSnippetPosition(snippet, {})


  # @api private
  setSnippetPosition: (snippet, { parentContainer, previous, next }) ->
    snippet.parentContainer = parentContainer
    snippet.previous = previous
    snippet.next = next

    if parentContainer
      previous.next = snippet if previous
      next.previous = snippet if next
      parentContainer.first = snippet unless snippet.previous?
      parentContainer.last = snippet unless snippet.next?



class SnippetDrag


  constructor: ({ snippet, page }) ->
    @snippet = snippet
    @page = page
    @$highlightedContainer = {}
    @onStart = $.proxy(@onStart, @)
    @onDrag = $.proxy(@onDrag, @)
    @onDrop = $.proxy(@onDrop, @)
    @classAdded = []


  onStart: () ->
    @$insertPreview = $("<div class='doc-drag-preview'>")
    @page.$body
      .append(@$insertPreview)
      .css('cursor', 'pointer')

    @page.blurFocusedElement()

    #todo get all valid containers


  # remeve classes added while dragging from tracked elements
  removeCssClasses: ->
    for $html in @classAdded
      $html
        .removeClass(docClass.afterDrop)
        .removeClass(docClass.beforeDrop)
    @classAdded = []


  isValidTarget: (target) ->
    if target.snippetElem && target.snippetElem.snippet != @snippet
      return true
    else if target.containerName
      return true

    false


  onDrag: (target, drag, cursor) ->
    if not @isValidTarget(target)
      $container = target = {}

    if target.containerName
      dom.maximizeContainerHeight(target.parent)
      $container = $(target.node)
    else if target.snippetElem
      dom.maximizeContainerHeight(target.snippetElem)
      $container = target.snippetElem.get$container()
      $container.addClass(docClass.containerHighlight)
    else
      $container = target = {}

    # highlighting
    if $container[0] != @$highlightedContainer[0]
      @$highlightedContainer.removeClass?(docClass.containerHighlight)
      @$highlightedContainer = $container
      @$highlightedContainer.addClass?(docClass.containerHighlight)

    # show drop target
    if target.coords
      coords = target.coords
      @$insertPreview
        .css({ left:"#{ coords.left }px", top:"#{ coords.top - 5}px", width:"#{ coords.width }px" })
        .show()
    else
      @$insertPreview.hide()


  onDrop: (drag) ->
    # @removeCssClasses()
    @page.$body.css('cursor', '')
    @$insertPreview.remove()
    @$highlightedContainer.removeClass?(docClass.containerHighlight)
    dom.restoreContainerHeight()
    target = drag.target

    if target and @isValidTarget(target)
      if snippetElem = target.snippetElem
        if target.position == 'before'
          snippetElem.snippet.before(@snippet)
        else
          snippetElem.snippet.after(@snippet)
      else if target.containerName
        target.parent.snippet.append(target.containerName, @snippet)
    else
      #consider: maybe add a 'drop failed' effect


class SnippetElem

  constructor: ({ @snippet, @$html, @editables, @containers, @images }) ->
    @template = @snippet.template
    @attachedToDom = false

    # add attributes and references to the html
    @$html
      .data('snippet', this)
      .addClass(docClass.snippet)
      .attr(docAttr.template, @template.identifier)

    @updateContent()


  updateContent: ->
    @content(@snippet.editables, @snippet.images)


  content: (content, images) ->
    for field, value of content
      @set(field, value)

    for field, value of images
      @setImage(field, value)


  getEditable: (name) ->
    if name?
      return @editables[name]
    else
      for name of @editables
        return @editables[name]


  setImage: (name, value) ->
    elem = @images[name]
    $(elem).attr('src', value)


  set: (editable, value) ->
    if arguments.length == 1
      value = editable
      editable = undefined

    if elem = @getEditable(editable)
      $(elem).html(value)
    else
      log.error 'cannot set value without editable name'


  get: (editable) ->
    if elem = @getEditable(editable)
      $(elem).html()
    else
      log.error 'cannot get value without editable name'


  append: (containerName, $elem) ->
    $container = $(@containers[containerName])
    $container.append($elem)


  attach: (renderer) ->
    return if @attachedToDom
    previous = @snippet.previous
    next = @snippet.next
    parentContainer = @snippet.parentContainer

    if previous? and
      (previousHtml = renderer.getSnippetElem(previous)) and
      previousHtml.attachedToDom
        previousHtml.$html.after(@$html)
        @attachedToDom = true
    else if next? and
      (nextHtml = renderer.getSnippetElem(next)) and
      nextHtml.attachedToDom
        nextHtml.$html.before(@$html)
        @attachedToDom = true
    else if parentContainer
      @appendToContainer(parentContainer, renderer)
      @attachedToDom = true

    this


  appendToContainer: (container, renderer) ->
    if container.isRoot
      renderer.$root.append(@$html)
    else
      snippetElem = renderer.getSnippetElem(container.parentSnippet)
      snippetElem.append(container.name, @$html)


  detach: ->
    @attachedToDom = false
    @$html.detach()


  get$container: ->
    $(dom.parentContainer(@$html[0]).node)


class SnippetNode

  attributePrefix = /^(x-|data-)/

  constructor: (@htmlNode) ->
    @parseAttributes()


  parseAttributes: () ->
    for attr in @htmlNode.attributes
      attributeName = attr.name
      normalizedName = attributeName.replace(attributePrefix, '')
      if type = templateAttrLookup[normalizedName]
        @isDataNode = true
        @type = type
        @name = attr.value || templateAttr.defaultValues[@type]

        if attributeName != docAttr[@type]
          @normalizeAttribute(attributeName)
        else if not attr.value
          @normalizeAttribute()

        return


  normalizeAttribute: (attr) ->
    @htmlNode.removeAttribute(attr) if attr
    @htmlNode.setAttribute(docAttr[@type], @name)

class SnippetNodeList


  constructor: (@all={}) ->
    @count = {}

  add: (node) ->
    @assertNodeNameNotUsed(node.name)

    @all[node.name] = node

    this[node.type] ||= {}
    this[node.type][node.name] = node.htmlNode

    @count[node.type] = if @count[node.type] then @count[node.type] + 1 else 1




  # @private
  assertNodeNameNotUsed: (name) ->
    if @all[name]
      log.error(
        """
        A node with the name "#{name}" was already added.
        Each node in a snippet requires a unique name, regardless of type.
        """
      )

# SnippetSelection
# ----------------
# Manage selection and manipulation of multiple snippets at once
class SnippetSelection

  constructor: () ->
    @snippets = []




# SnippetTemplateList
# -------------------
# Represents a repeatable Template inside another Template
#
# Consider: Instead of defining a list inside a template we could
# just define another template. If we can mark the position of the first
# and last element, we don't need a container as in the current implementation
#
# Consider: Implement limitations. An attribute like `list-repetitions="{1,3}"`
# could deifine how many elements can be created (here with a regex-like syntax).
class SnippetTemplateList

  constructor: (@name, $list) ->
    @$list = $list
    $item = @$list.children().first().detach()

    @_item = new Template(
      name: "#{ @name }-item",
      html: $item
    )


  # array with an object literal for every list item
  # if only one item is submitted then the wrapping array can be omitted
  content: (content) ->
    if !@isEmpty()
      @clear()

    if $.isArray(content)
      for listItem in content
        @add(listItem)
    else
      @add(content)


  # param is the same as in content()
  # but the elements are appended instead of replaced
  add: (listItems, events) ->
    if $.isArray(listItems)
      for listItem in listItems
        @add(listItem, events)
    else
      $newItem = @_item.create(listItems)

      # register events
      for event, func of events
        $newItem.on(event, func)

      @$list.append($newItem)


  # remove list item
  # if index is blank or -1, the last item is removed
  # the first list item has index == 0
  remove: (index) ->
    if index == undefined || index == -1
      @$list.children(":last").remove()
    else
      @$list.children(":nth-child(#{ index + 1 })").remove()


  clear: ($list) ->
    @$list.children().remove()


  isEmpty: ($list) ->
    !@$list.children().length

# SnippetTree
# -----------
# Livingdocs equivalent to the DOM tree.
# A snippet tree containes all the snippets of a page in hierarchical order.
#
# The root of the SnippetTree is a SnippetContainer. A SnippetContainer
# contains a list of snippets.
#
# snippets can have multible SnippetContainers themselves.
#
# ### Example:
#     - SnippetContainer (root)
#       - Snippet 'Hero'
#       - Snippet '2 Columns'
#         - SnippetContainer 'main'
#           - Snippet 'Title'
#         - SnippetContainer 'sidebar'
#           - Snippet 'Info-Box''
#
# ### Events:
# The first set of SnippetTree Events are concerned with layout changes like
# adding, removing or moving snippets.
#
# Consider: Have a documentFragment as the rootNode if no rootNode is given
# maybe this would help simplify some code (since snippets are always
# attached to the DOM).
class SnippetTree


  constructor: ({ content, design } = {}) ->
    @root = new SnippetContainer(isRoot: true)

    # initialize content before we set the snippet tree to the root
    # otherwise all the events will be triggered while building the tree
    if content? and design?
      @fromJson(content, design)

    @root.snippetTree = this

    @history = new History()
    @initializeEvents()


  # insert snippet at the beginning
  prepend: (snippet) ->
    @root.prepend(snippet)
    this


  # insert snippet at the end
  append: (snippet) ->
    @root.append(snippet)
    this


  initializeEvents: () ->

    # layout changes
    @snippetAdded = $.Callbacks()
    @snippetRemoved = $.Callbacks()
    @snippetMoved = $.Callbacks()

    # content changes
    @snippetContentChanged = $.Callbacks()
    @snippetHtmlChanged = $.Callbacks()
    @snippetSettingsChanged = $.Callbacks()

    @changed = $.Callbacks()


  # Traverse the whole snippet tree.
  each: (callback) ->
    @root.each(callback)


  eachContainer: (callback) ->
    @root.eachContainer(callback)


  # Traverse all containers and snippets
  all: (callback) ->
    @root.all(callback)


  find: (search) ->
    if typeof search == 'string'
      res = []
      @each (snippet) ->
        if snippet.identifier == search || snippet.template.name == search
          res.push(snippet)

      new SnippetArray(res)
    else
      new SnippetArray()


  detach: ->
    @root.snippetTree = undefined
    @each (snippet) ->
      snippet.snippetTree = undefined

    oldRoot = @root
    @root = new SnippetContainer(isRoot: true)

    oldRoot


  # eachWithParents: (snippet, parents) ->
  #   parents ||= []

  #   # traverse
  #   parents = parents.push(snippet)
  #   for name, snippetContainer of snippet.containers
  #     snippet = snippetContainer.first

  #     while (snippet)
  #       @eachWithParents(snippet, parents)
  #       snippet = snippet.next

  #   parents.splice(-1)


  # returns a readable string representation of the whole tree
  print: () ->
    output = 'SnippetTree\n-----------\n'

    addLine = (text, indentation = 0) ->
      output += "#{ Array(indentation + 1).join(" ") }#{ text }\n"

    walker = (snippet, indentation = 0) ->
      template = snippet.template
      addLine("- #{ template.title } (#{ template.identifier })", indentation)

      # traverse children
      for name, snippetContainer of snippet.containers
        addLine("#{ name }:", indentation + 2)
        walker(snippetContainer.first, indentation + 4) if snippetContainer.first

      # traverse siblings
      walker(snippet.next, indentation) if snippet.next

    walker(@root.first) if @root.first
    return output


  # Tree Change Events
  # ------------------
  # Raise events for Add, Remove and Move of snippets
  # These functions should only be called by snippetContainers

  attachingSnippet: (snippet, attachSnippetFunc) ->
    if snippet.snippetTree == this
      # move snippet
      attachSnippetFunc()
      @fireEvent('snippetMoved', snippet)
    else
      if snippet.snippetTree?
        # remove from other snippet tree
        snippet.snippetContainer.detachSnippet(snippet)

      snippet.descendantsAndSelf (descendant) =>
        descendant.snippetTree = this

      attachSnippetFunc()
      @fireEvent('snippetAdded', snippet)


  fireEvent: (event, args...) ->
    this[event].fire.apply(event, args)
    @changed.fire()


  detachingSnippet: (snippet, detachSnippetFunc) ->
    if snippet.snippetTree == this

      snippet.descendantsAndSelf (descendants) ->
        descendants.snippetTree = undefined

      detachSnippetFunc()
      @fireEvent('snippetRemoved', snippet)
    else
      log.error('cannot remove snippet from another SnippetTree')


  contentChanging: (snippet) ->
    @fireEvent('snippetContentChanged', snippet)


  # Serialization
  # -------------

  printJson: ->
    S.readableJson(@toJson())


  # returns a JSON representation of the whole tree
  toJson: ->
    json = {}
    json['content'] = []

    snippetToJson = (snippet, level, containerArray) ->
      snippetJson = snippet.toJson()
      containerArray.push snippetJson

      snippetJson

    walker = (snippet, level, jsonObj) ->
      snippetJson = snippetToJson(snippet, level, jsonObj)

      # traverse children
      for name, snippetContainer of snippet.containers
        containerArray = snippetJson.containers[snippetContainer.name] = []
        walker(snippetContainer.first, level + 1, containerArray) if snippetContainer.first

      # traverse siblings
      walker(snippet.next, level, jsonObj) if snippet.next

    walker(@root.first, 0, json['content']) if @root.first

    json


  fromJson: (json, design) ->
    @root.snippetTree = undefined
    for snippetJson in json.content
      snippet = Snippet.fromJson(snippetJson, design)
      @root.append(snippet)

    @root.snippetTree = this
    @root.each (snippet) =>
      snippet.snippetTree = this




stash = do ->
  initialized = false


  init: ->
    if not initialized
      initialized = true

      # store up to ten versions
      @store = new LimitedLocalstore('stash', 10)


  snapshot: ->
    @store.push(document.toJson())


  stash: ->
    @snapshot()
    document.reset()


  delete: ->
    @store.pop()


  get: ->
    @store.get()


  restore: ->
    json = @store.get()

    if json
      document.restore(json)
    else
      log.error('stash is empty')


  list: ->
    entries = for obj in @store.getIndex()
      { key: obj.key, date: new Date(obj.date).toString() }

    S.readableJson(entries)

# Template
# --------
# Parses snippet templates and creates snippet html.
#
# __Methods:__
# @snippet() create new snippets with content
#
# Consider: allow tags to be optional. These tags can then be hidden by
# the user. The template needs to know where to reinsert the tag if it is
# reinserted again.
# Options could be to set `display:none` or to remove the element and
# leave a marker instead.
# (a comment or a script tag like ember does for example)
#
# Consider: Replace lists with inline Templates. Inline
# Templates are repeatable and can only be used inside their
# defining snippet.
class Template


  constructor: ({ html, @namespace, @name, identifier, title, version } = {}) ->
    if not html
      log.error('Template: param html missing')

    if identifier
      { @namespace, @name } = Template.parseIdentifier(identifier)

    @identifier = if @namespace && @name
      "#{ @namespace }.#{ @name }"

    @version = version || 1

    @$template = $( @pruneHtml(html) ).wrap('<div>')
    @$wrap = @$template.parent()
    @title = title || S.humanize( @name )

    @editables = undefined
    @editableCount = 0
    @containers = undefined
    @containerCount = 0
    @defaults = {}

    @parseTemplate()
    @lists = @createLists()


  # create a new snippet instance from this template
  createSnippet: () ->
    new Snippet(template: this)


  createHtml: (snippet) ->
    snippet ||= @createSnippet()
    $html = @$template.clone()
    list = @getNodeLinks($html[0])

    snippetElem = new SnippetElem
      snippet: snippet
      $html: $html
      editables: list.editable
      containers: list.container
      images: list.image


  # todo
  pruneHtml: (html) ->
    # e.g. remove ids
    html


  # @param snippetNode: root DOM node of the snippet
  parseTemplate: () ->
    snippetNode = @$template[0]
    @directives = @getNodeLinks(snippetNode)
    @editables = @directives.editable
    @containers = @directives.container
    @editableCount = @directives.count.editable
    @containerCount = @directives.count.container

    for name, node of @editables
      @formatEditable(name, node)

    for name, node of @containers
      @formatContainer(name, node)


  # Find and store all DOM nodes which are editables or containers
  # in the html of a snippet or the html of a template.
  getNodeLinks: (snippetNode) ->
    iterator = new SnippetNodeIterator(snippetNode)
    list = new SnippetNodeList()

    while element = iterator.nextElement()
      node = new SnippetNode(element)
      list.add(node) if node.isDataNode

    list


  formatEditable: (name, elem) ->
    $elem = $(elem)
    $elem.addClass(docClass.editable)

    defaultValue = elem.innerHTML
    # not sure how to deal with default values in editables...
    # elem.innerHTML = ''

    if defaultValue
      @defaults[name] = defaultValue


  formatContainer: (name, elem) ->
    # remove all content fron a container from the template
    elem.innerHTML = ''


  createLists: () ->
    lists = {}
    @$wrap.find("[#{ docAttr.list }]").each( ->
      $list = $(this)
      listName = $list.attr("#{ docAttr.list }")
      lists[listName] = new SnippetTemplateList(listName, $list)
    )
    lists


  # alias to lists
  list: (listName) ->
    @lists[listName]


  # output the accepted content of the snippet
  # that can be passed to create
  # e.g: { title: "Itchy and Scratchy" }
  printDoc: () ->
    doc =
      identifier: @identifier
      editables: @editables
      containers: @containers

    S.readableJson(doc)


# Static functions
# ----------------

Template.parseIdentifier = (identifier) ->
  return unless identifier # silently fail on undefined or empty strings

  parts = identifier.split('.')
  if parts.length == 1
    { namespace: undefined, name: parts[0] }
  else if parts.length == 2
    { namespace: parts[0], name: parts[1] }
  else
    log.error("could not parse snippet template identifier: #{ identifier }")
    { namespace: undefined , name: undefined }



# Public API
# ----------
# Since the livingdocs-engine code is contained in its own function closure
# we expose our public API here explicitly.
#
#
# `doc()`: primary function interface similar to jquery
# with snippet selectors and stuff...
@doc = (search) ->
  document.find(search)


# Helper method to create chainable proxies.
# Works the same as $.proxy() *its mostly the same code ;)*
chainable = (fn, context) ->

  if typeof context == 'string'
    tmp = fn[ context ]
    context = fn
    fn = tmp

  # Simulated bind
  args = Array.prototype.slice.call( arguments, 2 )
  proxy = ->
    fn.apply( context || this, args.concat( Array.prototype.slice.call( arguments ) ) )
    doc

  proxy


setupApi = ->

  # Initialize the document
  @loadDocument = chainable(document, 'loadDocument')
  @ready = chainable(document.ready, 'add')

  # Add Templates to the documents
  @addDesign = chainable(document, 'addDesign')
  @getDesign = -> document.design

  # Print a list of all available snippets
  @listTemplates = $.proxy(document, 'listTemplates')

  # Append a snippet to the document
  # @param input: (String) snippet identifier e.g. "bootstrap.title" or (Snippet)
  # @return Snippet
  @add = $.proxy(document, 'add')

  # Create a new snippet instance (not inserted into the document)
  # @param identifier: (String) snippet identifier e.g. "bootstrap.title"
  # @return Snippet
  @create = $.proxy(document, 'createSnippet')

  # Json that can be used for saving of the document
  @toJson = $.proxy(document, 'toJson')
  @readableJson = ->
    S.readableJson(document.toJson())

  # Print the content of the snippetTree in a readable string
  @printTree = $.proxy(document, 'printTree')

  @eachContainer = chainable(document, 'eachContainer')
  @document = document

  @changed = chainable(document.changed, 'add')
  @DragDrop = DragDrop

  # Get help about a snippet
  # @param identifier: (String) snippet identifier e.g. "bootstrap.title"
  @help = $.proxy(document, 'help')


  # Stash
  # -----
  stash.init()
  @stash = $.proxy(stash, 'stash')
  @stash.snapshot = $.proxy(stash, 'snapshot')
  @stash.delete = $.proxy(stash, 'delete')
  @stash.restore = $.proxy(stash, 'restore')
  @stash.get = $.proxy(stash, 'get')
  @stash.list = $.proxy(stash, 'list')


  # For Plugins & Extensions
  # ------------------------

  # enable snippet finder plugins
  @fn = SnippetArray::


# API methods that are only available after the page has initialized
pageReady = ->
  page = document.page

  @restore = chainable(document, 'restore')

  # Events
  # ------
  @snippetFocused = chainable(page.focus.snippetFocus, 'add')
  @snippetBlurred = chainable(page.focus.snippetBlur, 'add')
  @textSelection = chainable(page.editableController.selection, 'add')
  @startDrag = $.proxy(page, 'startDrag')



# execute API setup
setupApi.call(doc)
doc.ready ->
  pageReady.call(doc)



