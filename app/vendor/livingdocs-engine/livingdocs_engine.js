(function() {
  var Design, DragDrop, EditableController, Focus, History, HistoryAction, InterfaceInjector, LimitedLocalstore, Loader, Page, Renderer, SnippetArray, SnippetContainer, SnippetDrag, SnippetModel, SnippetNode, SnippetNodeIterator, SnippetNodeList, SnippetSelection, SnippetTemplateList, SnippetTree, SnippetView, Template, chainable, chainableProxy, config, docAttr, docClass, document, dom, guid, htmlCompare, key, kickstart, localstore, log, mixins, n, name, pageReady, setupApi, stash, templateAttr, templateAttrLookup, v, value,
    __slice = [].slice;

  config = {
    wordSeparators: "./\\()\"':,.;<>~!#%^&*|+=[]{}`~?",
    attributePrefix: 'data'
  };

  docClass = {
    section: 'doc-section',
    snippet: 'doc-snippet',
    editable: 'doc-editable',
    "interface": 'doc-ui',
    snippetHighlight: 'doc-snippet-highlight',
    containerHighlight: 'doc-container-highlight',
    draggedPlaceholder: 'doc-dragged-placeholder',
    dragged: 'doc-dragged',
    beforeDrop: 'doc-before-drop',
    afterDrop: 'doc-after-drop',
    preventSelection: 'doc-no-selection',
    maximizedContainer: 'doc-js-maximized-container'
  };

  templateAttr = {
    editable: 'doc-editable',
    container: 'doc-container',
    image: 'doc-image',
    defaultValues: {
      editable: 'default',
      container: 'default',
      image: 'image'
    }
  };

  templateAttrLookup = {};

  for (n in templateAttr) {
    v = templateAttr[n];
    templateAttrLookup[v] = n;
  }

  docAttr = {
    template: 'doc-template'
  };

  for (name in templateAttr) {
    value = templateAttr[name];
    docAttr[name] = value;
  }

  if (config.attributePrefix) {
    for (key in docAttr) {
      value = docAttr[key];
      docAttr[key] = "" + config.attributePrefix + "-" + value;
    }
  }

  chainableProxy = function(chainedObj) {
    return function(fn, context) {
      var args, proxy, tmp;
      if (typeof context === 'string') {
        tmp = fn[context];
        context = fn;
        fn = tmp;
      }
      args = Array.prototype.slice.call(arguments, 2);
      proxy = function() {
        fn.apply(context || this, args.concat(Array.prototype.slice.call(arguments)));
        return chainedObj;
      };
      return proxy;
    };
  };

  guid = (function() {
    var idCounter, lastId;
    idCounter = lastId = void 0;
    return {
      next: function(user) {
        var nextId;
        if (user == null) {
          user = 'doc';
        }
        nextId = Date.now().toString(32);
        if (lastId === nextId) {
          idCounter += 1;
        } else {
          idCounter = 0;
          lastId = nextId;
        }
        return "" + user + "-" + nextId + idCounter;
      }
    };
  })();

  htmlCompare = (function() {
    return {
      empty: /^\s*$/,
      whitespace: /\s+/g,
      normalizeWhitespace: true,
      compareElement: function(a, b) {
        if (this.compareTag(a, b)) {
          if (this.compareAttributes(a, b)) {
            return true;
          }
        }
      },
      compareTag: function(a, b) {
        return this.getTag(a) === this.getTag(b);
      },
      getTag: function(node) {
        return node.namespaceURI + ':' + node.localName;
      },
      compareAttributes: function(a, b) {
        var attr, bValue, _i, _len, _ref;
        if (a.attributes.length === b.attributes.length) {
          _ref = a.attributes;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            attr = _ref[_i];
            bValue = b.getAttribute(attr.name);
            if (!this.compareAttributeValue(attr.name, attr.value, bValue)) {
              return false;
            }
          }
          return true;
        }
      },
      compareAttributeValue: function(attrName, aValue, bValue) {
        var aCleaned, aSorted, bCleaned, bSorted;
        if ((aValue == null) && (bValue == null)) {
          return true;
        }
        if ((aValue == null) || (bValue == null)) {
          return false;
        }
        switch (attrName) {
          case 'class':
            aSorted = aValue.split(' ').sort();
            bSorted = bValue.split(' ').sort();
            return aSorted.join(' ') === bSorted.join(' ');
          case 'style':
            aCleaned = this.prepareStyleValue(aValue);
            bCleaned = this.prepareStyleValue(bValue);
            return aCleaned === bCleaned;
          default:
            return aValue === bValue;
        }
      },
      prepareStyleValue: function(val) {
        val = $.trim(val).replace(/\s*:\s*/g, ':').replace(/\s*;\s*/g, ';').replace(/;$/g, '');
        return val.split(';').sort().join(';');
      },
      compareNode: function(a, b) {
        if ((a != null) && (b != null)) {
          if (a.nodeType === b.nodeType) {
            switch (a.nodeType) {
              case 1:
                return this.compareElement(a, b);
              case 3:
                return this.compareText(a, b);
              default:
                return log.error("HtmlCompare: nodeType " + a.nodeType + " not supported");
            }
          }
        }
      },
      compareText: function(a, b) {
        var valA, valB;
        if (this.normalizeWhitespace) {
          valA = $.trim(a.textContent).replace(this.whitespace, ' ');
          valB = $.trim(b.textContent).replace(this.whitespace, ' ');
          return valA === valB;
        } else {
          return a.nodeValue === b.nodeValue;
        }
      },
      isEmptyTextNode: function(textNode) {
        return this.empty.test(textNode.nodeValue);
      },
      compare: function(a, b) {
        var equivalent, nextInA, nextInB;
        if (typeof a === 'string') {
          a = $(a);
        }
        if (typeof b === 'string') {
          b = $(b);
        }
        if (a.jquery) {
          a = a[0];
        }
        if (b.jquery) {
          b = b[0];
        }
        nextInA = this.iterateComparables(a);
        nextInB = this.iterateComparables(b);
        equivalent = true;
        while (equivalent) {
          equivalent = this.compareNode(a = nextInA(), b = nextInB());
        }
        if ((a == null) && (b == null)) {
          return true;
        } else {
          return false;
        }
      },
      isComparable: function(node) {
        var nodeType;
        nodeType = node.nodeType;
        if (nodeType === 1 || (nodeType === 3 && !this.isEmptyTextNode(node))) {
          return true;
        }
      },
      iterateComparables: function(root) {
        var iterate,
          _this = this;
        iterate = this.iterate(root);
        return function() {
          var next;
          while (next = iterate()) {
            if (_this.isComparable(next)) {
              return next;
            }
          }
        };
      },
      iterate: function(root) {
        var current, next;
        current = next = root;
        return function() {
          var child;
          n = current = next;
          child = next = void 0;
          if (current) {
            if (child = n.firstChild) {
              next = child;
            } else {
              while ((n !== root) && !(next = n.nextSibling)) {
                n = n.parentNode;
              }
            }
          }
          return current;
        };
      }
    };
  })();

  jQuery.fn.outerHtml = jQuery.fn.outerHtml || function() {
    var el, error, error2;
    el = this[0];
    if (el) {
      if (typeof el.outerHTML !== 'undefined') {
        return el.outerHTML;
      }
      try {
        return (new XMLSerializer()).serializeToString(el);
      } catch (_error) {
        error = _error;
        try {
          return el.xml;
        } catch (_error) {
          error2 = _error;
        }
      }
    }
  };

  jQuery.fn.replaceClass = function(classToBeRemoved, classToBeAdded) {
    this.removeClass(classToBeRemoved);
    return this.addClass(classToBeAdded);
  };

  jQuery.fn.findIn = function(selector) {
    return this.find(selector).add(this.filter(selector));
  };

  LimitedLocalstore = (function() {
    function LimitedLocalstore(key, limit) {
      this.key = key;
      this.limit = limit;
      this.limit || (this.limit = 10);
      this.index = void 0;
    }

    LimitedLocalstore.prototype.push = function(obj) {
      var index, reference, removeRef;
      reference = {
        key: this.nextKey(),
        date: Date.now()
      };
      index = this.getIndex();
      index.push(reference);
      while (index.length > this.limit) {
        removeRef = index[0];
        index.splice(0, 1);
        localstore.remove(removeRef.key);
      }
      localstore.set(reference.key, obj);
      return localstore.set("" + this.key + "--index", index);
    };

    LimitedLocalstore.prototype.pop = function() {
      var index, reference;
      index = this.getIndex();
      if (index && index.length) {
        reference = index.pop();
        value = localstore.get(reference.key);
        localstore.remove(reference.key);
        this.setIndex();
        return value;
      } else {
        return void 0;
      }
    };

    LimitedLocalstore.prototype.get = function(num) {
      var index, reference;
      index = this.getIndex();
      if (index && index.length) {
        num || (num = index.length - 1);
        reference = index[num];
        return value = localstore.get(reference.key);
      } else {
        return void 0;
      }
    };

    LimitedLocalstore.prototype.clear = function() {
      var index, reference;
      index = this.getIndex();
      while (reference = index.pop()) {
        localstore.remove(reference.key);
      }
      return this.setIndex();
    };

    LimitedLocalstore.prototype.getIndex = function() {
      this.index || (this.index = localstore.get("" + this.key + "--index") || []);
      return this.index;
    };

    LimitedLocalstore.prototype.setIndex = function() {
      if (this.index) {
        return localstore.set("" + this.key + "--index", this.index);
      }
    };

    LimitedLocalstore.prototype.nextKey = function() {
      var addendum;
      addendum = Math.floor(Math.random() * 1e16).toString(32);
      return "" + this.key + "-" + addendum;
    };

    return LimitedLocalstore;

  })();

  localstore = (function() {
    var $;
    $ = jQuery;
    return {
      set: function(key, value) {
        return store.set(key, value);
      },
      get: function(key) {
        return store.get(key);
      },
      remove: function(key) {
        return store.remove(key);
      },
      clear: function() {
        return store.clear();
      },
      disbled: function() {
        return store.disabled;
      }
    };
  })();

  log = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (window.console != null) {
      if (args.length && args[args.length - 1] === 'trace') {
        args.pop();
        if (window.console.trace != null) {
          window.console.trace();
        }
      }
      window.console.log.apply(window.console, args);
      return void 0;
    }
  };

  (function() {
    var notify;
    notify = function(message, level) {
      if (level == null) {
        level = 'error';
      }
      if (typeof _rollbar !== "undefined" && _rollbar !== null) {
        _rollbar.push(new Error(message), function() {
          var _ref;
          if ((level === 'critical' || level === 'error') && (((_ref = window.console) != null ? _ref.error : void 0) != null)) {
            return window.console.error.call(window.console, message);
          } else {
            return log.call(void 0, message);
          }
        });
      } else {
        if (level === 'critical' || level === 'error') {
          throw new Error(message);
        } else {
          log.call(void 0, message);
        }
      }
      return void 0;
    };
    log.debug = function(message) {
      return notify(message, 'debug');
    };
    log.warn = function(message) {
      return notify(message, 'warning');
    };
    return log.error = function(message) {
      return notify(message, 'error');
    };
  })();

  mixins = function() {
    var Mixed, method, mixin, mixins, _i;
    mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    Mixed = function() {};
    for (_i = mixins.length - 1; _i >= 0; _i += -1) {
      mixin = mixins[_i];
      for (name in mixin) {
        method = mixin[name];
        Mixed.prototype[name] = method;
      }
    }
    return Mixed;
  };

  SnippetNodeIterator = (function() {
    function SnippetNodeIterator(root) {
      this.root = this._next = root;
    }

    SnippetNodeIterator.prototype.current = null;

    SnippetNodeIterator.prototype.hasNext = function() {
      return !!this._next;
    };

    SnippetNodeIterator.prototype.next = function() {
      var child, next;
      n = this.current = this._next;
      child = next = void 0;
      if (this.current) {
        child = n.firstChild;
        if (child && n.nodeType === 1 && !n.hasAttribute(docAttr.container)) {
          this._next = child;
        } else {
          next = null;
          while ((n !== this.root) && !(next = n.nextSibling)) {
            n = n.parentNode;
          }
          this._next = next;
        }
      }
      return this.current;
    };

    SnippetNodeIterator.prototype.nextElement = function() {
      while (this.next()) {
        if (this.current.nodeType === 1) {
          break;
        }
      }
      return this.current;
    };

    SnippetNodeIterator.prototype.detach = function() {
      return this.current = this._next = this.root = null;
    };

    return SnippetNodeIterator;

  })();

  stash = (function() {
    var initialized;
    initialized = false;
    return {
      init: function() {
        if (!initialized) {
          initialized = true;
          return this.store = new LimitedLocalstore('stash', 10);
        }
      },
      snapshot: function() {
        return this.store.push(document.toJson());
      },
      stash: function() {
        this.snapshot();
        return document.reset();
      },
      "delete": function() {
        return this.store.pop();
      },
      get: function() {
        return this.store.get();
      },
      restore: function() {
        var json;
        json = this.store.get();
        if (json) {
          return document.restore(json);
        } else {
          return log.error('stash is empty');
        }
      },
      list: function() {
        var entries, obj;
        entries = (function() {
          var _i, _len, _ref, _results;
          _ref = this.store.getIndex();
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            obj = _ref[_i];
            _results.push({
              key: obj.key,
              date: new Date(obj.date).toString()
            });
          }
          return _results;
        }).call(this);
        return words.readableJson(entries);
      }
    };
  })();

  this.words = (function() {
    return {
      humanize: function(str) {
        var uncamelized;
        uncamelized = $.trim(str).replace(/([a-z\d])([A-Z]+)/g, '$1 $2').toLowerCase();
        return this.titleize(uncamelized);
      },
      capitalize: function(str) {
        str = str == null ? '' : String(str);
        return str.charAt(0).toUpperCase() + str.slice(1);
      },
      titleize: function(str) {
        if (str == null) {
          return '';
        } else {
          return String(str).replace(/(?:^|\s)\S/g, function(c) {
            return c.toUpperCase();
          });
        }
      },
      snakeCase: function(str) {
        return $.trim(str).replace(/([A-Z])/g, '-$1').replace(/[-_\s]+/g, '-').toLowerCase();
      },
      prefix: function(prefix, string) {
        if (string.indexOf(prefix) === 0) {
          return string;
        } else {
          return "" + prefix + string;
        }
      },
      readableJson: function(obj) {
        return JSON.stringify(obj, null, 2);
      }
    };
  })();

  History = (function() {
    History.prototype.history = [];

    function History() {}

    History.prototype.add = function() {};

    History.prototype.saved = function() {};

    History.prototype.isDirty = function() {
      if (history.length === 0) {
        return false;
      }
    };

    return History;

  })();

  HistoryAction = (function() {
    function HistoryAction() {}

    return HistoryAction;

  })();

  SnippetArray = (function() {
    function SnippetArray(snippets) {
      this.snippets = snippets;
      if (this.snippets == null) {
        this.snippets = [];
      }
      this.createPseudoArray();
    }

    SnippetArray.prototype.createPseudoArray = function() {
      var index, result, _i, _len, _ref;
      _ref = this.snippets;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        result = _ref[index];
        this[index] = result;
      }
      this.length = this.snippets.length;
      if (this.snippets.length) {
        this.first = this[0];
        return this.last = this[this.snippets.length - 1];
      }
    };

    SnippetArray.prototype.each = function(callback) {
      var snippet, _i, _len, _ref;
      _ref = this.snippets;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        snippet = _ref[_i];
        callback(snippet);
      }
      return this;
    };

    SnippetArray.prototype.remove = function() {
      this.each(function(snippet) {
        return snippet.remove();
      });
      return this;
    };

    return SnippetArray;

  })();

  SnippetContainer = (function() {
    function SnippetContainer(_arg) {
      var isRoot;
      this.parentSnippet = _arg.parentSnippet, this.name = _arg.name, isRoot = _arg.isRoot;
      this.isRoot = isRoot != null;
      this.first = this.last = void 0;
    }

    SnippetContainer.prototype.prepend = function(snippet) {
      if (this.first) {
        this.insertBefore(this.first, snippet);
      } else {
        this.attachSnippet(snippet);
      }
      return this;
    };

    SnippetContainer.prototype.append = function(snippet) {
      if ((this.parentSnippet != null) && snippet === this.parentSnippet) {
        log.error('cannot append snippet to itself');
      }
      if (this.last) {
        this.insertAfter(this.last, snippet);
      } else {
        this.attachSnippet(snippet);
      }
      return this;
    };

    SnippetContainer.prototype.insertBefore = function(snippet, insertedSnippet) {
      var position;
      if (snippet.previous === insertedSnippet) {
        return;
      }
      if (snippet === insertedSnippet) {
        log.error('cannot insert snippet before itself');
      }
      position = {
        previous: snippet.previous,
        next: snippet,
        parentContainer: snippet.parentContainer
      };
      return this.attachSnippet(insertedSnippet, position);
    };

    SnippetContainer.prototype.insertAfter = function(snippet, insertedSnippet) {
      var position;
      if (snippet.next === insertedSnippet) {
        return;
      }
      if (snippet === insertedSnippet) {
        log.error('cannot insert snippet after itself');
      }
      position = {
        previous: snippet,
        next: snippet.next,
        parentContainer: snippet.parentContainer
      };
      return this.attachSnippet(insertedSnippet, position);
    };

    SnippetContainer.prototype.up = function(snippet) {
      if (snippet.previous != null) {
        return this.insertBefore(snippet.previous, snippet);
      }
    };

    SnippetContainer.prototype.down = function(snippet) {
      if (snippet.next != null) {
        return this.insertAfter(snippet.next, snippet);
      }
    };

    SnippetContainer.prototype.getSnippetTree = function() {
      var _ref;
      return this.snippetTree || ((_ref = this.parentSnippet) != null ? _ref.snippetTree : void 0);
    };

    SnippetContainer.prototype.each = function(callback) {
      var snippet, _results;
      snippet = this.first;
      _results = [];
      while (snippet) {
        snippet.descendantsAndSelf(callback);
        _results.push(snippet = snippet.next);
      }
      return _results;
    };

    SnippetContainer.prototype.eachContainer = function(callback) {
      callback(this);
      return this.each(function(snippet) {
        var snippetContainer, _ref, _results;
        _ref = snippet.containers;
        _results = [];
        for (name in _ref) {
          snippetContainer = _ref[name];
          _results.push(callback(snippetContainer));
        }
        return _results;
      });
    };

    SnippetContainer.prototype.all = function(callback) {
      callback(this);
      return this.each(function(snippet) {
        var snippetContainer, _ref, _results;
        callback(snippet);
        _ref = snippet.containers;
        _results = [];
        for (name in _ref) {
          snippetContainer = _ref[name];
          _results.push(callback(snippetContainer));
        }
        return _results;
      });
    };

    SnippetContainer.prototype.remove = function(snippet) {
      snippet.destroy();
      return this._detachSnippet(snippet);
    };

    SnippetContainer.prototype.ui = function() {
      var snippetTree;
      if (!this.uiInjector) {
        snippetTree = this.getSnippetTree();
        snippetTree.renderer.createInterfaceInjector(this);
      }
      return this.uiInjector;
    };

    SnippetContainer.prototype.attachSnippet = function(snippet, position) {
      var func, snippetTree,
        _this = this;
      if (position == null) {
        position = {};
      }
      func = function() {
        return _this.link(snippet, position);
      };
      if (snippetTree = this.getSnippetTree()) {
        return snippetTree.attachingSnippet(snippet, func);
      } else {
        return func();
      }
    };

    SnippetContainer.prototype._detachSnippet = function(snippet) {
      var func, snippetTree,
        _this = this;
      func = function() {
        return _this.unlink(snippet);
      };
      if (snippetTree = this.getSnippetTree()) {
        return snippetTree.detachingSnippet(snippet, func);
      } else {
        return func();
      }
    };

    SnippetContainer.prototype.link = function(snippet, position) {
      if (snippet.parentContainer) {
        this.unlink(snippet);
      }
      position.parentContainer || (position.parentContainer = this);
      return this.setSnippetPosition(snippet, position);
    };

    SnippetContainer.prototype.unlink = function(snippet) {
      var container, _ref, _ref1;
      container = snippet.parentContainer;
      if (container) {
        if (snippet.previous == null) {
          container.first = snippet.next;
        }
        if (snippet.next == null) {
          container.last = snippet.previous;
        }
        if ((_ref = snippet.next) != null) {
          _ref.previous = snippet.previous;
        }
        if ((_ref1 = snippet.previous) != null) {
          _ref1.next = snippet.next;
        }
        return this.setSnippetPosition(snippet, {});
      }
    };

    SnippetContainer.prototype.setSnippetPosition = function(snippet, _arg) {
      var next, parentContainer, previous;
      parentContainer = _arg.parentContainer, previous = _arg.previous, next = _arg.next;
      snippet.parentContainer = parentContainer;
      snippet.previous = previous;
      snippet.next = next;
      if (parentContainer) {
        if (previous) {
          previous.next = snippet;
        }
        if (next) {
          next.previous = snippet;
        }
        if (snippet.previous == null) {
          parentContainer.first = snippet;
        }
        if (snippet.next == null) {
          return parentContainer.last = snippet;
        }
      }
    };

    return SnippetContainer;

  })();

  SnippetModel = (function() {
    function SnippetModel(_arg) {
      var id, _ref;
      _ref = _arg != null ? _arg : {}, this.template = _ref.template, id = _ref.id;
      if (!this.template) {
        log.error('cannot instantiate snippet without template reference');
      }
      this.initializeContainers();
      this.initializeEditables();
      this.initializeImages();
      this.id = id || guid.next();
      this.identifier = this.template.identifier;
      this.next = void 0;
      this.previous = void 0;
      this.snippetTree = void 0;
    }

    SnippetModel.prototype.initializeContainers = function() {
      var containerName, _results;
      this.containerCount = this.template.directives.count.container;
      _results = [];
      for (containerName in this.template.directives.container) {
        this.containers || (this.containers = {});
        _results.push(this.containers[containerName] = new SnippetContainer({
          name: containerName,
          parentSnippet: this
        }));
      }
      return _results;
    };

    SnippetModel.prototype.initializeEditables = function() {
      var editableName, _results;
      this.editableCount = this.template.directives.count.editable;
      _results = [];
      for (editableName in this.template.directives.editable) {
        this.editables || (this.editables = {});
        _results.push(this.editables[editableName] = void 0);
      }
      return _results;
    };

    SnippetModel.prototype.initializeImages = function() {
      var imageName, _results;
      this.imageCount = this.template.directives.count.image;
      _results = [];
      for (imageName in this.template.directives.image) {
        this.images || (this.images = {});
        _results.push(this.images[imageName] = void 0);
      }
      return _results;
    };

    SnippetModel.prototype.hasImages = function() {
      return this.imageCount > 0;
    };

    SnippetModel.prototype.hasContainers = function() {
      return this.containers != null;
    };

    SnippetModel.prototype.before = function(snippetModel) {
      if (snippetModel) {
        this.parentContainer.insertBefore(this, snippetModel);
        return this;
      } else {
        return this.previous;
      }
    };

    SnippetModel.prototype.after = function(snippetModel) {
      if (snippetModel) {
        this.parentContainer.insertAfter(this, snippetModel);
        return this;
      } else {
        return this.next;
      }
    };

    SnippetModel.prototype.append = function(containerName, snippetModel) {
      if (arguments.length === 1) {
        snippetModel = containerName;
        containerName = templateAttr.defaultValues.container;
      }
      this.containers[containerName].append(snippetModel);
      return this;
    };

    SnippetModel.prototype.prepend = function(containerName, snippetModel) {
      if (arguments.length === 1) {
        snippetModel = containerName;
        containerName = templateAttr.defaultValues.container;
      }
      this.containers[containerName].prepend(snippetModel);
      return this;
    };

    SnippetModel.prototype.set = function(name, value) {
      var _ref, _ref1;
      if ((_ref = this.editables) != null ? _ref.hasOwnProperty(name) : void 0) {
        if (this.editables[name] !== value) {
          this.editables[name] = value;
          if (this.snippetTree) {
            return this.snippetTree.contentChanging(this);
          }
        }
      } else if ((_ref1 = this.images) != null ? _ref1.hasOwnProperty(name) : void 0) {
        if (this.images[name] !== value) {
          this.images[name] = value;
          if (this.snippetTree) {
            return this.snippetTree.contentChanging(this);
          }
        }
      } else {
        return log.error("set error: " + this.identifier + " has no content named " + name);
      }
    };

    SnippetModel.prototype.get = function(name) {
      var _ref, _ref1;
      if ((_ref = this.editables) != null ? _ref.hasOwnProperty(name) : void 0) {
        return this.editables[name];
      } else if ((_ref1 = this.images) != null ? _ref1.hasOwnProperty(name) : void 0) {
        return this.images[name];
      } else {
        return log.error("get error: " + this.identifier + " has no name named " + name);
      }
    };

    SnippetModel.prototype.copy = function() {
      return log.warn("SnippetModel#copy() is not implemented yet.");
    };

    SnippetModel.prototype.copyWithoutContent = function() {
      return this.template.createModel();
    };

    SnippetModel.prototype.hasEditables = function() {
      return this.editables != null;
    };

    SnippetModel.prototype.up = function() {
      this.parentContainer.up(this);
      return this;
    };

    SnippetModel.prototype.down = function() {
      this.parentContainer.down(this);
      return this;
    };

    SnippetModel.prototype.remove = function() {
      return this.parentContainer.remove(this);
    };

    SnippetModel.prototype.destroy = function() {
      if (this.uiInjector) {
        return this.uiInjector.remove();
      }
    };

    SnippetModel.prototype.getParent = function() {
      var _ref;
      return (_ref = this.parentContainer) != null ? _ref.parentSnippet : void 0;
    };

    SnippetModel.prototype.ui = function() {
      if (!this.uiInjector) {
        this.snippetTree.renderer.createInterfaceInjector(this);
      }
      return this.uiInjector;
    };

    SnippetModel.prototype.parents = function(callback) {
      var snippetModel, _results;
      snippetModel = this;
      _results = [];
      while ((snippetModel = snippetModel.getParent())) {
        _results.push(callback(snippetModel));
      }
      return _results;
    };

    SnippetModel.prototype.children = function(callback) {
      var snippetContainer, snippetModel, _ref, _results;
      _ref = this.containers;
      _results = [];
      for (name in _ref) {
        snippetContainer = _ref[name];
        snippetModel = snippetContainer.first;
        _results.push((function() {
          var _results1;
          _results1 = [];
          while (snippetModel) {
            callback(snippetModel);
            _results1.push(snippetModel = snippetModel.next);
          }
          return _results1;
        })());
      }
      return _results;
    };

    SnippetModel.prototype.descendants = function(callback) {
      var snippetContainer, snippetModel, _ref, _results;
      _ref = this.containers;
      _results = [];
      for (name in _ref) {
        snippetContainer = _ref[name];
        snippetModel = snippetContainer.first;
        _results.push((function() {
          var _results1;
          _results1 = [];
          while (snippetModel) {
            callback(snippetModel);
            snippetModel.descendants(callback);
            _results1.push(snippetModel = snippetModel.next);
          }
          return _results1;
        })());
      }
      return _results;
    };

    SnippetModel.prototype.descendantsAndSelf = function(callback) {
      callback(this);
      return this.descendants(callback);
    };

    SnippetModel.prototype.descendantContainers = function(callback) {
      return this.descendantsAndSelf(function(snippetModel) {
        var snippetContainer, _ref, _results;
        _ref = snippetModel.containers;
        _results = [];
        for (name in _ref) {
          snippetContainer = _ref[name];
          _results.push(callback(snippetContainer));
        }
        return _results;
      });
    };

    SnippetModel.prototype.allDescendants = function(callback) {
      var _this = this;
      return this.descendantsAndSelf(function(snippetModel) {
        var snippetContainer, _ref, _results;
        if (snippetModel !== _this) {
          callback(snippetModel);
        }
        _ref = snippetModel.containers;
        _results = [];
        for (name in _ref) {
          snippetContainer = _ref[name];
          _results.push(callback(snippetContainer));
        }
        return _results;
      });
    };

    SnippetModel.prototype.childrenAndSelf = function(callback) {
      callback(this);
      return this.children(callback);
    };

    SnippetModel.prototype.toJson = function() {
      var json, _ref, _ref1;
      json = {
        id: this.id,
        identifier: this.identifier
      };
      if (this.hasEditables()) {
        json.editables = {};
        _ref = this.editables;
        for (name in _ref) {
          value = _ref[name];
          json.editables[name] = value;
        }
      }
      for (name in this.images) {
        json.images || (json.images = {});
        _ref1 = this.images;
        for (name in _ref1) {
          value = _ref1[name];
          json.images[name] = value;
        }
      }
      for (name in this.containers) {
        json.containers || (json.containers = {});
        json.containers[name] = [];
      }
      return json;
    };

    return SnippetModel;

  })();

  SnippetModel.fromJson = function(json, design) {
    var child, containerName, editableName, imageName, model, snippetArray, template, _i, _len, _ref, _ref1, _ref2;
    template = design.get(json.identifier);
    if (template == null) {
      log.error("error while deserializing snippet: unknown template identifier '" + json.identifier + "'");
    }
    model = new SnippetModel({
      template: template,
      id: json.id
    });
    _ref = json.editables;
    for (editableName in _ref) {
      value = _ref[editableName];
      if (model.editables.hasOwnProperty(editableName)) {
        model.editables[editableName] = value;
      } else {
        log.error("error while deserializing snippet: unknown editable " + editableName);
      }
    }
    _ref1 = json.images;
    for (imageName in _ref1) {
      value = _ref1[imageName];
      if (model.images.hasOwnProperty(imageName)) {
        model.images[imageName] = value;
      } else {
        log.error("error while deserializing snippet: unknown image " + imageName);
      }
    }
    _ref2 = json.containers;
    for (containerName in _ref2) {
      snippetArray = _ref2[containerName];
      if (!model.containers.hasOwnProperty(containerName)) {
        log.error("error while deserializing snippet: unknown container " + containerName);
      }
      if (snippetArray) {
        if (!$.isArray(snippetArray)) {
          log.error("error while deserializing snippet: container is not array " + containerName);
        }
        for (_i = 0, _len = snippetArray.length; _i < _len; _i++) {
          child = snippetArray[_i];
          model.append(containerName, SnippetModel.fromJson(child, design));
        }
      }
    }
    return model;
  };

  SnippetTree = (function() {
    function SnippetTree(_arg) {
      var content, design, _ref;
      _ref = _arg != null ? _arg : {}, content = _ref.content, design = _ref.design;
      this.root = new SnippetContainer({
        isRoot: true
      });
      if ((content != null) && (design != null)) {
        this.fromJson(content, design);
      }
      this.root.snippetTree = this;
      this.history = new History();
      this.initializeEvents();
    }

    SnippetTree.prototype.prepend = function(snippet) {
      this.root.prepend(snippet);
      return this;
    };

    SnippetTree.prototype.append = function(snippet) {
      this.root.append(snippet);
      return this;
    };

    SnippetTree.prototype.initializeEvents = function() {
      this.snippetAdded = $.Callbacks();
      this.snippetRemoved = $.Callbacks();
      this.snippetMoved = $.Callbacks();
      this.snippetContentChanged = $.Callbacks();
      this.snippetHtmlChanged = $.Callbacks();
      this.snippetSettingsChanged = $.Callbacks();
      return this.changed = $.Callbacks();
    };

    SnippetTree.prototype.each = function(callback) {
      return this.root.each(callback);
    };

    SnippetTree.prototype.eachContainer = function(callback) {
      return this.root.eachContainer(callback);
    };

    SnippetTree.prototype.all = function(callback) {
      return this.root.all(callback);
    };

    SnippetTree.prototype.find = function(search) {
      var res;
      if (typeof search === 'string') {
        res = [];
        this.each(function(snippet) {
          if (snippet.identifier === search || snippet.template.id === search) {
            return res.push(snippet);
          }
        });
        return new SnippetArray(res);
      } else {
        return new SnippetArray();
      }
    };

    SnippetTree.prototype.detach = function() {
      var oldRoot;
      this.root.snippetTree = void 0;
      this.each(function(snippet) {
        return snippet.snippetTree = void 0;
      });
      oldRoot = this.root;
      this.root = new SnippetContainer({
        isRoot: true
      });
      return oldRoot;
    };

    SnippetTree.prototype.print = function() {
      var addLine, output, walker;
      output = 'SnippetTree\n-----------\n';
      addLine = function(text, indentation) {
        if (indentation == null) {
          indentation = 0;
        }
        return output += "" + (Array(indentation + 1).join(" ")) + text + "\n";
      };
      walker = function(snippet, indentation) {
        var snippetContainer, template, _ref;
        if (indentation == null) {
          indentation = 0;
        }
        template = snippet.template;
        addLine("- " + template.title + " (" + template.identifier + ")", indentation);
        _ref = snippet.containers;
        for (name in _ref) {
          snippetContainer = _ref[name];
          addLine("" + name + ":", indentation + 2);
          if (snippetContainer.first) {
            walker(snippetContainer.first, indentation + 4);
          }
        }
        if (snippet.next) {
          return walker(snippet.next, indentation);
        }
      };
      if (this.root.first) {
        walker(this.root.first);
      }
      return output;
    };

    SnippetTree.prototype.attachingSnippet = function(snippet, attachSnippetFunc) {
      var _this = this;
      if (snippet.snippetTree === this) {
        attachSnippetFunc();
        return this.fireEvent('snippetMoved', snippet);
      } else {
        if (snippet.snippetTree != null) {
          snippet.snippetContainer.detachSnippet(snippet);
        }
        snippet.descendantsAndSelf(function(descendant) {
          return descendant.snippetTree = _this;
        });
        attachSnippetFunc();
        return this.fireEvent('snippetAdded', snippet);
      }
    };

    SnippetTree.prototype.fireEvent = function() {
      var args, event;
      event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this[event].fire.apply(event, args);
      return this.changed.fire();
    };

    SnippetTree.prototype.detachingSnippet = function(snippet, detachSnippetFunc) {
      if (snippet.snippetTree === this) {
        snippet.descendantsAndSelf(function(descendants) {
          return descendants.snippetTree = void 0;
        });
        detachSnippetFunc();
        return this.fireEvent('snippetRemoved', snippet);
      } else {
        return log.error('cannot remove snippet from another SnippetTree');
      }
    };

    SnippetTree.prototype.contentChanging = function(snippet) {
      return this.fireEvent('snippetContentChanged', snippet);
    };

    SnippetTree.prototype.printJson = function() {
      return words.readableJson(this.toJson());
    };

    SnippetTree.prototype.toJson = function() {
      var json, snippetToJson, walker;
      json = {};
      json['content'] = [];
      snippetToJson = function(snippet, level, containerArray) {
        var snippetJson;
        snippetJson = snippet.toJson();
        containerArray.push(snippetJson);
        return snippetJson;
      };
      walker = function(snippet, level, jsonObj) {
        var containerArray, snippetContainer, snippetJson, _ref;
        snippetJson = snippetToJson(snippet, level, jsonObj);
        _ref = snippet.containers;
        for (name in _ref) {
          snippetContainer = _ref[name];
          containerArray = snippetJson.containers[snippetContainer.name] = [];
          if (snippetContainer.first) {
            walker(snippetContainer.first, level + 1, containerArray);
          }
        }
        if (snippet.next) {
          return walker(snippet.next, level, jsonObj);
        }
      };
      if (this.root.first) {
        walker(this.root.first, 0, json['content']);
      }
      return json;
    };

    SnippetTree.prototype.fromJson = function(json, design) {
      var snippet, snippetJson, _i, _len, _ref,
        _this = this;
      this.root.snippetTree = void 0;
      _ref = json.content;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        snippetJson = _ref[_i];
        snippet = SnippetModel.fromJson(snippetJson, design);
        this.root.append(snippet);
      }
      this.root.snippetTree = this;
      return this.root.each(function(snippet) {
        return snippet.snippetTree = _this;
      });
    };

    return SnippetTree;

  })();

  SnippetNode = (function() {
    var attributePrefix;

    attributePrefix = /^(x-|data-)/;

    function SnippetNode(htmlNode) {
      this.htmlNode = htmlNode;
      this.parseAttributes();
    }

    SnippetNode.prototype.parseAttributes = function() {
      var attr, attributeName, normalizedName, type, _i, _len, _ref;
      _ref = this.htmlNode.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        attributeName = attr.name;
        normalizedName = attributeName.replace(attributePrefix, '');
        if (type = templateAttrLookup[normalizedName]) {
          this.isDataNode = true;
          this.type = type;
          this.name = attr.value || templateAttr.defaultValues[this.type];
          if (attributeName !== docAttr[this.type]) {
            this.normalizeAttribute(attributeName);
          } else if (!attr.value) {
            this.normalizeAttribute();
          }
          return;
        }
      }
    };

    SnippetNode.prototype.normalizeAttribute = function(attr) {
      if (attr) {
        this.htmlNode.removeAttribute(attr);
      }
      return this.htmlNode.setAttribute(docAttr[this.type], this.name);
    };

    return SnippetNode;

  })();

  SnippetNodeList = (function() {
    function SnippetNodeList(all) {
      this.all = all != null ? all : {};
      this.count = {};
    }

    SnippetNodeList.prototype.add = function(node) {
      var _name;
      this.assertNodeNameNotUsed(node);
      this.all[node.name] = node;
      this[_name = node.type] || (this[_name] = {});
      this[node.type][node.name] = node.htmlNode;
      return this.count[node.type] = this.count[node.type] ? this.count[node.type] + 1 : 1;
    };

    SnippetNodeList.prototype.assertNodeNameNotUsed = function(node) {
      if (this.all[node.name]) {
        return log.error("" + node.type + " Template parsing error: " + docAttr[node.type] + "=\"" + node.name + "\".\n\"" + node.name + "\" is a duplicate name.");
      }
    };

    return SnippetNodeList;

  })();

  SnippetTemplateList = (function() {
    function SnippetTemplateList(name, $list) {
      var $item;
      this.name = name;
      this.$list = $list;
      $item = this.$list.children().first().detach();
      this._item = new Template({
        id: "" + this.id + "-item",
        html: $item
      });
    }

    SnippetTemplateList.prototype.content = function(content) {
      var listItem, _i, _len, _results;
      if (!this.isEmpty()) {
        this.clear();
      }
      if ($.isArray(content)) {
        _results = [];
        for (_i = 0, _len = content.length; _i < _len; _i++) {
          listItem = content[_i];
          _results.push(this.add(listItem));
        }
        return _results;
      } else {
        return this.add(content);
      }
    };

    SnippetTemplateList.prototype.add = function(listItems, events) {
      var $newItem, event, func, listItem, _i, _len, _results;
      if ($.isArray(listItems)) {
        _results = [];
        for (_i = 0, _len = listItems.length; _i < _len; _i++) {
          listItem = listItems[_i];
          _results.push(this.add(listItem, events));
        }
        return _results;
      } else {
        $newItem = this._item.create(listItems);
        for (event in events) {
          func = events[event];
          $newItem.on(event, func);
        }
        return this.$list.append($newItem);
      }
    };

    SnippetTemplateList.prototype.remove = function(index) {
      if (index === void 0 || index === -1) {
        return this.$list.children(":last").remove();
      } else {
        return this.$list.children(":nth-child(" + (index + 1) + ")").remove();
      }
    };

    SnippetTemplateList.prototype.clear = function($list) {
      return this.$list.children().remove();
    };

    SnippetTemplateList.prototype.isEmpty = function($list) {
      return !this.$list.children().length;
    };

    return SnippetTemplateList;

  })();

  Template = (function() {
    function Template(_arg) {
      var html, identifier, styles, title, version, weight, _ref, _ref1;
      _ref = _arg != null ? _arg : {}, html = _ref.html, this.namespace = _ref.namespace, this.id = _ref.id, identifier = _ref.identifier, title = _ref.title, styles = _ref.styles, weight = _ref.weight, version = _ref.version;
      if (!html) {
        log.error('Template: param html missing');
      }
      if (identifier) {
        _ref1 = Template.parseIdentifier(identifier), this.namespace = _ref1.namespace, this.id = _ref1.id;
      }
      this.identifier = this.namespace && this.id ? "" + this.namespace + "." + this.id : void 0;
      this.version = version || 1;
      this.$template = $(this.pruneHtml(html)).wrap('<div>');
      this.$wrap = this.$template.parent();
      this.title = title || words.humanize(this.id);
      this.styles = styles || [];
      this.weight = weight;
      this.editables = void 0;
      this.editableCount = 0;
      this.containers = void 0;
      this.containerCount = 0;
      this.defaults = {};
      this.parseTemplate();
      this.lists = this.createLists();
    }

    Template.prototype.createModel = function() {
      return new SnippetModel({
        template: this
      });
    };

    Template.prototype.createView = function(snippetModel) {
      var $html, list, snippetView;
      snippetModel || (snippetModel = this.createModel());
      $html = this.$template.clone();
      list = this.getNodeLinks($html[0]);
      return snippetView = new SnippetView({
        model: snippetModel,
        $html: $html,
        editables: list.editable,
        containers: list.container,
        images: list.image
      });
    };

    Template.prototype.pruneHtml = function(html) {
      return html;
    };

    Template.prototype.parseTemplate = function() {
      var node, snippetNode, _ref, _ref1, _results;
      snippetNode = this.$template[0];
      this.directives = this.getNodeLinks(snippetNode);
      this.editables = this.directives.editable;
      this.containers = this.directives.container;
      this.editableCount = this.directives.count.editable;
      this.containerCount = this.directives.count.container;
      _ref = this.editables;
      for (name in _ref) {
        node = _ref[name];
        this.formatEditable(name, node);
      }
      _ref1 = this.containers;
      _results = [];
      for (name in _ref1) {
        node = _ref1[name];
        _results.push(this.formatContainer(name, node));
      }
      return _results;
    };

    Template.prototype.getNodeLinks = function(snippetNode) {
      var element, iterator, list, node;
      iterator = new SnippetNodeIterator(snippetNode);
      list = new SnippetNodeList();
      while (element = iterator.nextElement()) {
        node = new SnippetNode(element);
        if (node.isDataNode) {
          list.add(node);
        }
      }
      return list;
    };

    Template.prototype.formatEditable = function(name, elem) {
      var $elem, defaultValue;
      $elem = $(elem);
      $elem.addClass(docClass.editable);
      defaultValue = elem.innerHTML;
      if (defaultValue) {
        return this.defaults[name] = defaultValue;
      }
    };

    Template.prototype.formatContainer = function(name, elem) {
      return elem.innerHTML = '';
    };

    Template.prototype.createLists = function() {
      var lists;
      lists = {};
      this.$wrap.find("[" + docAttr.list + "]").each(function() {
        var $list, listName;
        $list = $(this);
        listName = $list.attr("" + docAttr.list);
        return lists[listName] = new SnippetTemplateList(listName, $list);
      });
      return lists;
    };

    Template.prototype.list = function(listName) {
      return this.lists[listName];
    };

    Template.prototype.printDoc = function() {
      var doc;
      doc = {
        identifier: this.identifier,
        editables: this.editables ? Object.keys(this.editables) : void 0,
        containers: this.containers ? Object.keys(this.containers) : void 0
      };
      return words.readableJson(doc);
    };

    return Template;

  })();

  Template.parseIdentifier = function(identifier) {
    var parts;
    if (!identifier) {
      return;
    }
    parts = identifier.split('.');
    if (parts.length === 1) {
      return {
        namespace: void 0,
        id: parts[0]
      };
    } else if (parts.length === 2) {
      return {
        namespace: parts[0],
        id: parts[1]
      };
    } else {
      log.error("could not parse snippet template identifier: " + identifier);
      return {
        namespace: void 0,
        id: void 0
      };
    }
  };

  Design = (function() {
    function Design(design) {
      var groups, templates;
      templates = design.templates || design.snippets;
      config = design.config;
      groups = design.config.groups || design.groups;
      this.namespace = (config != null ? config.namespace : void 0) || 'livingdocs-templates';
      this.css = config.css;
      this.js = config.js;
      this.fonts = config.fonts;
      this.templates = [];
      this.templatesCount = 0;
      this.groups = {};
      this.addTemplates(templates);
      this.addGroups(groups);
    }

    Design.prototype.add = function(template) {
      var object;
      this.templatesCount = this.templatesCount + 1;
      object = new Template({
        namespace: this.namespace,
        id: template.id,
        title: template.title,
        styles: template.styles,
        html: template.html,
        weight: this.templatesCount
      });
      return this.templates.push(object);
    };

    Design.prototype.addTemplates = function(templates) {
      var template, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = templates.length; _i < _len; _i++) {
        template = templates[_i];
        _results.push(this.add(template));
      }
      return _results;
    };

    Design.prototype.addGroups = function(collection) {
      var group, template, templates, _i, _len, _ref, _results;
      _results = [];
      for (key in collection) {
        group = collection[key];
        templates = {};
        _ref = group.templates;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          template = _ref[_i];
          templates[template] = this.get(template);
        }
        _results.push(this.groups[key] = new Object({
          title: group.title,
          templates: templates
        }));
      }
      return _results;
    };

    Design.prototype.remove = function(identifier) {
      var _this = this;
      return this.checkNamespace(identifier, function(id) {
        return _this.templates.splice(_this.getIndex(id), 1);
      });
    };

    Design.prototype.get = function(identifier) {
      var _this = this;
      return this.checkNamespace(identifier, function(id) {
        var template;
        template = void 0;
        _this.each(function(t, index) {
          if (t.id === id) {
            return template = t;
          }
        });
        return template;
      });
    };

    Design.prototype.getIndex = function(identifier) {
      var _this = this;
      return this.checkNamespace(identifier, function(id) {
        var index;
        index = void 0;
        _this.each(function(t, i) {
          if (t.id === id) {
            return index = i;
          }
        });
        return index;
      });
    };

    Design.prototype.checkNamespace = function(identifier, callback) {
      var id, namespace, _ref;
      _ref = Template.parseIdentifier(identifier), namespace = _ref.namespace, id = _ref.id;
      if (!namespace || this.namespace === namespace) {
        return callback(id);
      } else {
        return log.error("design " + this.namespace + ": cannot get template with different namespace " + namespace + " ");
      }
    };

    Design.prototype.each = function(callback) {
      var index, template, _i, _len, _ref, _results;
      _ref = this.templates;
      _results = [];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        template = _ref[index];
        _results.push(callback(template, index));
      }
      return _results;
    };

    Design.prototype.list = function() {
      var templates;
      templates = [];
      this.each(function(template) {
        return templates.push(template.identifier);
      });
      return templates;
    };

    Design.prototype.info = function(identifier) {
      var template;
      template = this.get(identifier);
      return template.printDoc();
    };

    return Design;

  })();

  document = (function() {
    var doBeforeDocumentReady, documentReady, waitingCalls,
      _this = this;
    waitingCalls = 1;
    documentReady = function() {
      waitingCalls -= 1;
      if (waitingCalls === 0) {
        return document.ready.fire();
      }
    };
    doBeforeDocumentReady = function() {
      waitingCalls += 1;
      return documentReady;
    };
    return {
      initialized: false,
      uniqueId: 0,
      ready: $.Callbacks('memory once'),
      changed: $.Callbacks(),
      init: function(_arg) {
        var design, json, rootNode, _ref,
          _this = this;
        _ref = _arg != null ? _arg : {}, design = _ref.design, json = _ref.json, rootNode = _ref.rootNode;
        if (this.initialized) {
          log.error('document is already initialized');
        }
        this.initialized = true;
        this.loadDesign(design);
        this.snippetTree = json && this.design ? new SnippetTree({
          content: json,
          design: this.design
        }) : new SnippetTree();
        this.snippetTree.changed.add(function() {
          return _this.changed.fire();
        });
        this.page = new Page();
        if (this.design.css) {
          this.page.loader.css(this.design.css, doBeforeDocumentReady());
        }
        rootNode || (rootNode = this.page.getDocumentSection()[0]);
        this.renderer = new Renderer({
          snippetTree: this.snippetTree,
          rootNode: rootNode,
          page: this.page
        });
        this.ready.add(function() {
          return _this.renderer.render();
        });
        return documentReady();
      },
      loadDesign: function(design) {
        return this.design = new Design(design);
      },
      eachContainer: function(callback) {
        return this.snippetTree.eachContainer(callback);
      },
      add: function(input) {
        var snippet;
        if (jQuery.type(input) === 'string') {
          snippet = this.createModel(input);
        } else {
          snippet = input;
        }
        if (snippet) {
          this.snippetTree.append(snippet);
        }
        return snippet;
      },
      createModel: function(identifier) {
        var template;
        template = this.getTemplate(identifier);
        if (template) {
          return template.createModel();
        }
      },
      find: function(search) {
        return this.snippetTree.find(search);
      },
      printTree: function() {
        return this.snippetTree.print();
      },
      toJson: function() {
        var json;
        json = this.snippetTree.toJson();
        json['meta'] = {
          title: void 0,
          author: void 0,
          created: void 0,
          published: void 0
        };
        return json;
      },
      restore: function(contentJson, resetFirst) {
        if (resetFirst == null) {
          resetFirst = true;
        }
        if (resetFirst) {
          this.reset();
        }
        this.snippetTree.fromJson(contentJson, this.design);
        return this.renderer.render();
      },
      reset: function() {
        this.renderer.clear();
        return this.snippetTree.detach();
      },
      getTemplate: function(identifier) {
        var template, _ref;
        template = (_ref = this.design) != null ? _ref.get(identifier) : void 0;
        if (!template) {
          log.error("could not find template " + identifier);
        }
        return template;
      }
    };
  })();

  dom = (function() {
    var sectionRegex, snippetRegex;
    snippetRegex = new RegExp("(?: |^)" + docClass.snippet + "(?: |$)");
    sectionRegex = new RegExp("(?: |^)" + docClass.section + "(?: |$)");
    return {
      findSnippetView: function(node) {
        var view;
        node = this.getElementNode(node);
        while (node && node.nodeType === 1) {
          if (snippetRegex.test(node.className)) {
            view = this.getSnippetView(node);
            return view;
          }
          node = node.parentNode;
        }
        return void 0;
      },
      findContainer: function(node) {
        var containerName, view;
        node = this.getElementNode(node);
        while (node && node.nodeType === 1) {
          if (node.hasAttribute(docAttr.container)) {
            containerName = node.getAttribute(docAttr.container);
            if (!sectionRegex.test(node.className)) {
              view = this.findSnippetView(node);
            }
            return {
              node: node,
              containerName: containerName,
              snippetView: view
            };
          }
          node = node.parentNode;
        }
        return {};
      },
      getImageName: function(node) {
        var imageName;
        if (node.hasAttribute(docAttr.image)) {
          imageName = node.getAttribute(docAttr.image);
          return imageName;
        }
      },
      getEditableName: function(node) {
        var imageName;
        if (node.hasAttribute(docAttr.editable)) {
          imageName = node.getAttribute(docAttr.editable);
          return editableName;
        }
      },
      dropTarget: function(node, _arg) {
        var containerName, coords, insertSnippet, left, pos, top, view;
        top = _arg.top, left = _arg.left;
        node = this.getElementNode(node);
        while (node && node.nodeType === 1) {
          if (node.hasAttribute(docAttr.container)) {
            containerName = node.getAttribute(docAttr.container);
            if (!sectionRegex.test(node.className)) {
              insertSnippet = this.getPositionInContainer($(node), {
                top: top,
                left: left
              });
              if (insertSnippet) {
                coords = this.getInsertPosition(insertSnippet.$elem[0], insertSnippet.position);
                return {
                  snippetView: insertSnippet.snippetView,
                  position: insertSnippet.position,
                  coords: coords
                };
              } else {
                view = this.findSnippetView(node);
                return {
                  containerName: containerName,
                  parent: view,
                  node: node
                };
              }
            }
          } else if (snippetRegex.test(node.className)) {
            pos = this.getPositionInSnippet($(node), {
              top: top,
              left: left
            });
            view = this.getSnippetView(node);
            coords = this.getInsertPosition(node, pos.position);
            return {
              snippetView: view,
              position: pos.position,
              coords: coords
            };
          } else if (sectionRegex.test(node.className)) {
            return {
              root: true
            };
          }
          node = node.parentNode;
        }
        return {};
      },
      getInsertPosition: function(elem, position) {
        var rect;
        rect = this.getBoundingClientRect(elem);
        if (position === 'before') {
          return {
            top: rect.top,
            left: rect.left,
            width: rect.width
          };
        } else {
          return {
            top: rect.bottom,
            left: rect.left,
            width: rect.width
          };
        }
      },
      getPositionInSnippet: function($elem, _arg) {
        var elemBottom, elemHeight, elemTop, left, top;
        top = _arg.top, left = _arg.left;
        elemTop = $elem.offset().top;
        elemHeight = $elem.outerHeight();
        elemBottom = elemTop + elemHeight;
        if (this.distance(top, elemTop) < this.distance(top, elemBottom)) {
          return {
            position: 'before'
          };
        } else {
          return {
            position: 'after'
          };
        }
      },
      getPositionInContainer: function($container, _arg) {
        var $snippets, closest, insertSnippet, left, top,
          _this = this;
        top = _arg.top, left = _arg.left;
        $snippets = $container.find("." + docClass.snippet);
        closest = void 0;
        insertSnippet = void 0;
        $snippets.each(function(index, elem) {
          var $elem, elemBottom, elemHeight, elemTop;
          $elem = $(elem);
          elemTop = $elem.offset().top;
          elemHeight = $elem.outerHeight();
          elemBottom = elemTop + elemHeight;
          if (!closest || _this.distance(top, elemTop) < closest) {
            closest = _this.distance(top, elemTop);
            insertSnippet = {
              $elem: $elem,
              position: 'before'
            };
          }
          if (!closest || _this.distance(top, elemBottom) < closest) {
            closest = _this.distance(top, elemBottom);
            insertSnippet = {
              $elem: $elem,
              position: 'after'
            };
          }
          if (insertSnippet) {
            return insertSnippet.snippetView = _this.getSnippetView(insertSnippet.$elem[0]);
          }
        });
        return insertSnippet;
      },
      distance: function(a, b) {
        if (a > b) {
          return a - b;
        } else {
          return b - a;
        }
      },
      maximizeContainerHeight: function(view) {
        var $elem, $parent, elem, outer, parentHeight, _ref, _results;
        if (view.template.containerCount > 1) {
          _ref = view.containers;
          _results = [];
          for (name in _ref) {
            elem = _ref[name];
            $elem = $(elem);
            if ($elem.hasClass(docClass.maximizedContainer)) {
              continue;
            }
            $parent = $elem.parent();
            parentHeight = $parent.height();
            outer = $elem.outerHeight(true) - $elem.height();
            $elem.height(parentHeight - outer);
            _results.push($elem.addClass(docClass.maximizedContainer));
          }
          return _results;
        }
      },
      restoreContainerHeight: function() {
        return $("." + docClass.maximizedContainer).css('height', '').removeClass(docClass.maximizedContainer);
      },
      getElementNode: function(node) {
        if (node != null ? node.jquery : void 0) {
          return node[0];
        } else if ((node != null ? node.nodeType : void 0) === 3) {
          return node.parentNode;
        } else {
          return node;
        }
      },
      getSnippetView: function(node) {
        return $(node).data('snippet');
      },
      getBoundingClientRect: function(node) {
        var coords, scrollX, scrollY;
        coords = node.getBoundingClientRect();
        scrollX = window.pageXOffset !== void 0 ? window.pageXOffset : (document.documentElement || window.document.body.parentNode || window.document.body).scrollLeft;
        scrollY = window.pageYOffset !== void 0 ? window.pageYOffset : (document.documentElement || window.document.body.parentNode || window.document.body).scrollTop;
        coords = {
          top: coords.top + scrollY,
          bottom: coords.bottom + scrollY,
          left: coords.left + scrollX,
          right: coords.right + scrollX
        };
        coords.height = coords.bottom - coords.top;
        coords.width = coords.right - coords.left;
        return coords;
      }
    };
  })();

  DragDrop = (function() {
    function DragDrop(options) {
      this.defaultOptions = $.extend({
        longpressDelay: 0,
        longpressDistanceLimit: 10,
        minDistance: 0,
        direct: false,
        preventDefault: true,
        createPlaceholder: DragDrop.placeholder
      }, options);
      this.drag = {};
      this.$origin = void 0;
      this.$dragged = void 0;
    }

    DragDrop.prototype.mousedown = function($origin, event, options) {
      var _this = this;
      if (options == null) {
        options = {};
      }
      this.reset();
      this.drag.initialized = true;
      this.options = $.extend({}, this.defaultOptions, options);
      this.drag.startPoint = {
        left: event.pageX,
        top: event.pageY
      };
      this.$origin = $origin;
      if (this.options.longpressDelay && this.options.longpressDistanceLimit) {
        this.drag.timeout = setTimeout(function() {
          return _this.start();
        }, this.options.longpressDelay);
      }
      if (this.options.preventDefault) {
        return event.preventDefault();
      }
    };

    DragDrop.prototype.start = function() {
      var mouseLeft, mouseTop, _ref;
      this.drag.started = true;
      mouseLeft = this.drag.startPoint.left;
      mouseTop = this.drag.startPoint.top;
      if (typeof this.options.onDragStart === 'function') {
        this.options.onDragStart.call(this, this.drag, {
          left: mouseLeft,
          top: mouseTop
        });
      }
      $(window.document.body).addClass(docClass.preventSelection);
      if (this.options.direct) {
        this.$dragged = this.$origin;
      } else {
        this.$dragged = this.options.createPlaceholder(this.drag, this.$origin);
      }
      if (this.drag.fixed) {
        this.drag.$body = $(window.document.body);
      }
      this.move(mouseLeft, mouseTop);
      if (!this.direct) {
        this.$dragged.appendTo(window.document.body).show();
        return (_ref = this.$origin) != null ? _ref.addClass(docClass.dragged) : void 0;
      }
    };

    DragDrop.prototype.move = function(mouseLeft, mouseTop, event) {
      var left, top;
      if (this.drag.started) {
        if (this.drag.mouseToSnippet) {
          left = mouseLeft - this.drag.mouseToSnippet.left;
          top = mouseTop - this.drag.mouseToSnippet.top;
        } else {
          left = mouseLeft;
          top = mouseTop;
        }
        if (this.drag.fixed) {
          top = top - this.drag.$body.scrollTop();
          left = left - this.drag.$body.scrollLeft();
        }
        if (left < 2) {
          left = 2;
        }
        if (top < 2) {
          top = 2;
        }
        this.$dragged.css({
          position: 'absolute',
          left: "" + left + "px",
          top: "" + top + "px"
        });
        if (!this.direct) {
          return this.dropTarget(mouseLeft, mouseTop, event);
        }
      } else if (this.drag.initialized) {
        if (this.options.longpressDelay && this.options.longpressDistanceLimit) {
          if (this.distance({
            left: mouseLeft,
            top: mouseTop
          }, this.drag.startPoint) > this.options.longpressDistanceLimit) {
            this.reset();
          }
        }
        if (this.options.minDistance && this.distance({
          left: mouseLeft,
          top: mouseTop
        }, this.drag.startPoint) > this.options.minDistance) {
          return this.start();
        }
      }
    };

    DragDrop.prototype.drop = function() {
      if (this.drag.started) {
        if (typeof this.options.onDrop === 'function') {
          this.options.onDrop.call(this, this.drag, this.$origin);
        }
      }
      return this.reset();
    };

    DragDrop.prototype.dropTarget = function(mouseLeft, mouseTop, event) {
      var dragTarget, elem;
      if (this.$dragged && event) {
        elem = void 0;
        if (event.clientX && event.clientY) {
          this.$dragged.hide();
          elem = window.document.elementFromPoint(event.clientX, event.clientY);
          this.$dragged.show();
        }
        if (elem) {
          dragTarget = dom.dropTarget(elem, {
            top: mouseTop,
            left: mouseLeft
          });
          this.drag.target = dragTarget;
        } else {
          this.drag.target = {};
        }
        if (typeof this.options.onDrag === 'function') {
          return this.options.onDrag.call(this, this.drag.target, this.drag, {
            left: mouseLeft,
            top: mouseTop
          });
        }
      }
    };

    DragDrop.prototype.distance = function(pointA, pointB) {
      var distX, distY;
      if (!pointA || !pointB) {
        return void 0;
      }
      distX = pointA.left - pointB.left;
      distY = pointA.top - pointB.top;
      return Math.sqrt((distX * distX) + (distY * distY));
    };

    DragDrop.prototype.reset = function() {
      if (this.drag.initialized) {
        if (this.drag.timeout) {
          clearTimeout(this.drag.timeout);
        }
        if (this.drag.preview) {
          this.drag.preview.remove();
        }
        if (this.$dragged && this.$dragged !== this.$origin) {
          this.$dragged.remove();
        }
        if (this.$origin) {
          this.$origin.removeClass(docClass.dragged);
          this.$origin.show();
        }
        $(window.document.body).removeClass(docClass.preventSelection);
        this.drag = {};
        this.$origin = void 0;
        return this.$dragged = void 0;
      }
    };

    return DragDrop;

  })();

  DragDrop.cloneOrigin = function(drag, $origin) {
    var backgroundColor, draggedCopy, hasBackgroundColor, marginLeft, marginTop, snippetOffset, snippetWidth;
    if (!drag.mouseToSnippet) {
      snippetOffset = $origin.offset();
      marginTop = parseFloat($origin.css("margin-top"));
      marginLeft = parseFloat($origin.css("margin-left"));
      drag.mouseToSnippet = {
        left: mouseLeft - snippetOffset.left + marginLeft,
        top: mouseTop - snippetOffset.top + marginTop
      };
    }
    snippetWidth = drag.width || $origin.width();
    draggedCopy = $origin.clone();
    draggedCopy.css({
      position: "absolute",
      width: snippetWidth
    }).removeClass(docClass.snippetHighlight).addClass(docClass.draggedPlaceholder);
    backgroundColor = $origin.css("background-color");
    hasBackgroundColor = backgroundColor !== "transparent" && backgroundColor !== "rgba(0, 0, 0, 0)";
    if (!hasBackgroundColor) {
      draggedCopy.css({
        "background-color": "#fff"
      });
    }
    return draggedCopy;
  };

  DragDrop.placeholder = function(drag) {
    var $placeholder, numberOfDraggedElems, snippetWidth, template;
    snippetWidth = drag.width;
    numberOfDraggedElems = 1;
    if (!drag.mouseToSnippet) {
      drag.mouseToSnippet = {
        left: 2,
        top: -15
      };
    }
    template = "<div class=\"doc-drag-placeholder-item\">\n  <span class=\"doc-drag-counter\">" + numberOfDraggedElems + "</span>\n  Selected Item\n</div>";
    $placeholder = $(template);
    if (snippetWidth) {
      $placeholder.css({
        width: snippetWidth
      });
    }
    return $placeholder.css({
      position: "absolute"
    });
  };

  EditableController = (function() {
    function EditableController(page) {
      var controller;
      this.page = page;
      this.lastMouseEvent = null;
      controller = this;
      window.document.body.onmousedown = function(event) {
        return controller.lastMouseEvent = event;
      };
      window.document.body.onmouseup = function(event) {
        return controller.lastMouseEvent = event;
      };
      Editable.init({
        log: false
      });
      this.selection = $.Callbacks();
      Editable.focus($.proxy(this.focus, this)).blur($.proxy(this.blur, this)).insert($.proxy(this.insert, this)).merge($.proxy(this.merge, this)).split($.proxy(this.split, this)).selection($.proxy(this.selectionChanged, this));
    }

    EditableController.prototype.add = function(nodes) {
      return Editable.add(nodes);
    };

    EditableController.prototype.focus = function(element) {
      var snippetView;
      snippetView = dom.findSnippetView(element);
      return this.page.focus.editableFocused(element, snippetView);
    };

    EditableController.prototype.blur = function(element) {
      var editableName, snippetView;
      snippetView = dom.findSnippetView(element);
      this.page.focus.editableBlurred(element, snippetView);
      editableName = element.getAttribute(docAttr.editable);
      return snippetView.model.set(editableName, element.innerHTML);
    };

    EditableController.prototype.insert = function(element, direction, cursor) {
      var copy, newView, template, view;
      view = dom.findSnippetView(element);
      if (view.model.editableCount === 1) {
        template = document.design.get('text');
        copy = template.createModel();
        newView = direction === 'before' ? (view.model.before(copy), view.prev()) : (view.model.after(copy), view.next());
        if (newView) {
          newView.focus();
        }
      }
      return false;
    };

    EditableController.prototype.merge = function(element, direction, cursor) {
      var mergedView, view;
      view = dom.findSnippetView(element);
      if (view.model.editableCount === 1) {
        mergedView = direction === 'before' ? view.prev() : view.next();
        if (mergedView) {
          mergedView.focus();
        }
        if (mergedView.template === view.template) {
          view.model.remove();
        }
      }
      log('engine: merge');
      return false;
    };

    EditableController.prototype.split = function(element, before, after, cursor) {
      var snippetView;
      snippetView = dom.findSnippetView(element);
      log('engine: split');
      return false;
    };

    EditableController.prototype.selectionChanged = function(element, selection) {
      var snippetView;
      snippetView = dom.findSnippetView(element);
      return this.selection.fire(snippetView, element, selection, this.lastMouseEvent);
    };

    return EditableController;

  })();

  Focus = (function() {
    function Focus() {
      this.editableNode = void 0;
      this.snippetView = void 0;
      this.snippetFocus = $.Callbacks();
      this.snippetBlur = $.Callbacks();
    }

    Focus.prototype.setFocus = function(snippetView, editableNode) {
      if (editableNode !== this.editableNode) {
        this.resetEditable();
        this.editableNode = editableNode;
      }
      if (snippetView !== this.snippetView) {
        this.resetSnippetView();
        if (snippetView) {
          this.snippetView = snippetView;
          return this.snippetFocus.fire(this.snippetView);
        }
      }
    };

    Focus.prototype.editableFocused = function(editableNode, snippetView) {
      if (this.editableNode !== editableNode) {
        snippetView || (snippetView = dom.findSnippetView(editableNode));
        return this.setFocus(snippetView, editableNode);
      }
    };

    Focus.prototype.editableBlurred = function(editableNode) {
      if (this.editableNode === editableNode) {
        return this.setFocus(this.snippetView, void 0);
      }
    };

    Focus.prototype.snippetFocused = function(snippetView) {
      if (this.snippetView !== snippetView) {
        return this.setFocus(snippetView, void 0);
      }
    };

    Focus.prototype.blur = function() {
      return this.setFocus(void 0, void 0);
    };

    Focus.prototype.resetEditable = function() {
      if (this.editableNode) {
        return this.editableNode = void 0;
      }
    };

    Focus.prototype.resetSnippetView = function() {
      var previous;
      if (this.snippetView) {
        previous = this.snippetView;
        this.snippetView = void 0;
        return this.snippetBlur.fire(previous);
      }
    };

    return Focus;

  })();

  InterfaceInjector = (function() {
    function InterfaceInjector(_arg) {
      var _ref, _ref1, _ref2;
      this.snippet = _arg.snippet, this.snippetContainer = _arg.snippetContainer, this.renderer = _arg.renderer;
      if (this.snippet && !((_ref = this.snippet.snippetView) != null ? _ref.attachedToDom : void 0)) {
        log.error('snippet is not attached to the DOM');
      }
      if (this.snippetContainer) {
        if (!this.snippetContainer.isRoot && !((_ref1 = this.snippetContainer.parentSnippet) != null ? (_ref2 = _ref1.snippetView) != null ? _ref2.attachedToDom : void 0 : void 0)) {
          log.error('snippetContainer is not attached to the DOM');
        }
      }
    }

    InterfaceInjector.prototype.before = function($elem) {
      if (this.snippet) {
        this.beforeInjecting($elem);
        return this.snippet.snippetView.$html.before($elem);
      } else {
        return log.error('cannot use before on a snippetContainer');
      }
    };

    InterfaceInjector.prototype.after = function($elem) {
      if (this.snippet) {
        this.beforeInjecting($elem);
        return this.snippet.snippetView.$html.after($elem);
      } else {
        return log.error('cannot use after on a snippetContainer');
      }
    };

    InterfaceInjector.prototype.append = function($elem) {
      if (this.snippetContainer) {
        this.beforeInjecting($elem);
        return this.renderer.appendToContainer(this.snippetContainer, $elem);
      } else {
        return log.error('cannot use append on a snippet');
      }
    };

    InterfaceInjector.prototype.remove = function() {
      var $elem, _i, _len, _ref;
      _ref = this.injected;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        $elem = _ref[_i];
        $elem.remove();
      }
      return this.injected = void 0;
    };

    InterfaceInjector.prototype.beforeInjecting = function($elem) {
      this.injected || (this.injected = []);
      this.injected.push($elem);
      return $elem.addClass(docClass["interface"]);
    };

    return InterfaceInjector;

  })();

  kickstart = (function() {
    return {
      init: function(destination, design) {
        var domElements,
          _this = this;
        domElements = $(destination).children().not('script');
        $(destination).html('<div class="doc-section"></div>');
        doc.init({
          design: design
        });
        return doc.ready(function() {
          var domElementToSnippetName, parseContainers, parseSnippets, setEditables;
          domElementToSnippetName = function(element) {
            if (element.tagName) {
              return $.camelCase(element.tagName.toLowerCase());
            } else {
              return null;
            }
          };
          parseContainers = function(parent, data) {
            var child, children, containers, element, elements, _i, _j, _len, _len1, _results;
            containers = parent.containers ? Object.keys(parent.containers) : [];
            if (containers.length === 1 && containers.indexOf('default') !== -1 && !$(data).children('default').length) {
              children = $(data).children();
              for (_i = 0, _len = children.length; _i < _len; _i++) {
                child = children[_i];
                parseSnippets(parent, 'default', child);
              }
            }
            elements = $(containers.join(','), data);
            _results = [];
            for (_j = 0, _len1 = elements.length; _j < _len1; _j++) {
              element = elements[_j];
              children = $(element).children();
              _results.push((function() {
                var _k, _len2, _results1;
                _results1 = [];
                for (_k = 0, _len2 = children.length; _k < _len2; _k++) {
                  child = children[_k];
                  _results1.push(parseSnippets(parent, domElementToSnippetName(element), child));
                }
                return _results1;
              })());
            }
            return _results;
          };
          parseSnippets = function(parentContainer, region, data) {
            var snippet;
            snippet = doc.create(domElementToSnippetName(data));
            parentContainer.append(region, snippet);
            parseContainers(snippet, data);
            return setEditables(snippet, data);
          };
          setEditables = function(snippet, data) {
            var child, _results;
            if (snippet.hasEditables()) {
              _results = [];
              for (key in snippet.editables) {
                snippet.set(key, null);
                child = $(key + ':first', data).get()[0];
                if (!child) {
                  _results.push(snippet.set(key, data.innerHTML));
                } else {
                  _results.push(snippet.set(key, child.innerHTML));
                }
              }
              return _results;
            }
          };
          return domElements.each(function(index, element) {
            var row;
            row = doc.add(domElementToSnippetName(element));
            parseContainers(row, element);
            return setEditables(row, element);
          });
        });
      }
    };
  })();

  Loader = (function() {
    function Loader() {
      this.loadedCssFiles = [];
    }

    Loader.prototype.replaceCss = function(cssUrl, callback) {
      this.removeCss();
      return this.css(cssUrl, callback);
    };

    Loader.prototype.css = function(cssUrl, callback) {
      var filesToLoad, url;
      if (!$.isArray(cssUrl)) {
        cssUrl = [cssUrl];
      }
      cssUrl = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = cssUrl.length; _i < _len; _i++) {
          url = cssUrl[_i];
          this.loadedCssFiles.push(url);
          _results.push(words.prefix('css!', url));
        }
        return _results;
      }).call(this);
      filesToLoad = cssUrl.length;
      return yepnope({
        load: cssUrl,
        callback: function() {
          filesToLoad -= 1;
          if (callback && filesToLoad <= 0) {
            return callback();
          }
        }
      });
    };

    Loader.prototype.removeCss = function(cssUrl) {
      var url, _i, _len;
      if ((cssUrl != null) && !$.isArray(cssUrl)) {
        cssUrl = [cssUrl];
      }
      cssUrl = cssUrl || this.loadedCssFiles;
      for (_i = 0, _len = cssUrl.length; _i < _len; _i++) {
        url = cssUrl[_i];
        $("link[rel=stylesheet][href~='" + url + "']").remove();
      }
      return this.loadedCssFiles = [];
    };

    return Loader;

  })();

  Page = (function() {
    function Page() {
      this.$document = $(window.document);
      this.$body = $(window.document.body);
      this.loader = new Loader();
      this.focus = new Focus();
      this.imageClick = $.Callbacks();
      this.editableController = new EditableController(this);
      this.snippetDragDrop = new DragDrop({
        longpressDelay: 400,
        longpressDistanceLimit: 10,
        preventDefault: false
      });
      this.$document.on('click.livingdocs', $.proxy(this.click, this)).on('mousedown.livingdocs', $.proxy(this.mousedown, this)).on('dragstart', $.proxy(this.browserDragStart, this));
    }

    Page.prototype.browserDragStart = function(event) {
      event.preventDefault();
      return event.stopPropagation();
    };

    Page.prototype.removeListeners = function() {
      this.$document.off('.livingdocs');
      return this.$document.off('.livingdocs-drag');
    };

    Page.prototype.getDocumentSection = function(_arg) {
      var $root, rootNode;
      rootNode = (_arg != null ? _arg : {}).rootNode;
      if (!rootNode) {
        $root = $("." + docClass.section).first();
      } else {
        $root = $(rootNode).addClass("." + docClass.section);
      }
      if (!$root.length) {
        log.error('no rootNode found');
      }
      return $root;
    };

    Page.prototype.mousedown = function(event) {
      var snippetView;
      if (event.which !== 1) {
        return;
      }
      snippetView = dom.findSnippetView(event.target);
      if (snippetView) {
        return this.startDrag({
          snippetView: snippetView,
          dragDrop: this.snippetDragDrop
        });
      }
    };

    Page.prototype.startDrag = function(_arg) {
      var $snippet, dragDrop, snippet, snippetDrag, snippetView,
        _this = this;
      snippet = _arg.snippet, snippetView = _arg.snippetView, dragDrop = _arg.dragDrop;
      if (!(snippet || snippetView)) {
        return;
      }
      if (snippetView) {
        snippet = snippetView.model;
      }
      this.$document.on('mousemove.livingdocs-drag', function(event) {
        return dragDrop.move(event.pageX, event.pageY, event);
      });
      this.$document.on('mouseup.livingdocs-drag', function() {
        dragDrop.drop();
        return _this.$document.off('.livingdocs-drag');
      });
      snippetDrag = new SnippetDrag({
        snippet: snippet,
        page: this
      });
      if (snippetView) {
        $snippet = snippetView.$html;
      }
      return dragDrop.mousedown($snippet, event, {
        onDragStart: snippetDrag.onStart,
        onDrag: snippetDrag.onDrag,
        onDrop: snippetDrag.onDrop
      });
    };

    Page.prototype.click = function(event) {
      var imageName, snippetView;
      snippetView = dom.findSnippetView(event.target);
      if (snippetView) {
        this.focus.snippetFocused(snippetView);
        if (imageName = dom.getImageName(event.target)) {
          return this.imageClick.fire(snippetView, imageName, event);
        }
      } else {
        return this.focus.blur();
      }
    };

    Page.prototype.getFocusedElement = function() {
      return window.document.activeElement;
    };

    Page.prototype.blurFocusedElement = function() {
      var focusedElement;
      this.focus.setFocus(void 0);
      focusedElement = this.getFocusedElement();
      if (focusedElement) {
        return $(focusedElement).blur();
      }
    };

    return Page;

  })();

  Renderer = (function() {
    function Renderer(_arg) {
      var rootNode;
      this.snippetTree = _arg.snippetTree, rootNode = _arg.rootNode, this.page = _arg.page;
      if (!this.snippetTree) {
        log.error('no snippet tree specified');
      }
      if (!rootNode) {
        log.error('no root node specified');
      }
      this.$root = $(rootNode);
      this.setupPageListeners();
      this.setupSnippetTreeListeners();
      this.snippets = {};
    }

    Renderer.prototype.setupPageListeners = function() {
      this.page.focus.snippetFocus.add($.proxy(this, 'highlightSnippet'));
      return this.page.focus.snippetBlur.add($.proxy(this, 'removeSnippetHighlight'));
    };

    Renderer.prototype.setupSnippetTreeListeners = function() {
      this.snippetTree.snippetAdded.add($.proxy(this, 'snippetAdded'));
      this.snippetTree.snippetRemoved.add($.proxy(this, 'snippetRemoved'));
      this.snippetTree.snippetMoved.add($.proxy(this, 'snippetMoved'));
      return this.snippetTree.snippetContentChanged.add($.proxy(this, 'snippetContentChanged'));
    };

    Renderer.prototype.snippetAdded = function(model) {
      var view;
      view = this.ensureSnippetView(model);
      return this.updateDomPosition(view);
    };

    Renderer.prototype.snippetRemoved = function(model) {
      var view;
      if (view = this.getSnippetView(model)) {
        if (view.attachedToDom) {
          this.detachFromDom(view);
          return delete this.snippets[model.id];
        }
      }
    };

    Renderer.prototype.snippetMoved = function(model) {
      var view;
      view = this.ensureSnippetView(model);
      return this.updateDomPosition(view);
    };

    Renderer.prototype.snippetContentChanged = function(model) {
      var view;
      view = this.ensureSnippetView(model);
      if (!view.attachedToDom) {
        this.insertIntoDom(view);
      }
      return view.updateContent();
    };

    Renderer.prototype.getSnippetView = function(model) {
      if (model) {
        return this.snippets[model.id];
      }
    };

    Renderer.prototype.ensureSnippetView = function(model) {
      if (!model) {
        return;
      }
      return this.snippets[model.id] || this.createSnippetView(model);
    };

    Renderer.prototype.createSnippetView = function(model) {
      var view;
      view = model.template.createView(model);
      return this.snippets[model.id] = view;
    };

    Renderer.prototype.render = function() {
      var _this = this;
      this.$root.empty();
      return this.snippetTree.each(function(model) {
        var view;
        view = _this.ensureSnippetView(model);
        return _this.insertIntoDom(view);
      });
    };

    Renderer.prototype.clear = function() {
      var _this = this;
      this.snippetTree.each(function(model) {
        var view;
        view = _this.getSnippetView(model);
        return view != null ? view.attachedToDom = false : void 0;
      });
      return this.$root.empty();
    };

    Renderer.prototype.redraw = function() {
      this.clear();
      return this.render();
    };

    Renderer.prototype.updateDomPosition = function(snippetView) {
      if (snippetView.attachedToDom) {
        this.detachFromDom(snippetView);
      }
      return this.insertIntoDom(snippetView);
    };

    Renderer.prototype.insertIntoDom = function(snippetView) {
      snippetView.attach(this);
      if (!snippetView.attachedToDom) {
        log.error('could not insert snippet into Dom');
      }
      this.afterDomInsert(snippetView);
      return this;
    };

    Renderer.prototype.afterDomInsert = function(snippetView) {
      var editableNodes, node;
      editableNodes = (function() {
        var _ref, _results;
        _ref = snippetView.editables;
        _results = [];
        for (name in _ref) {
          node = _ref[name];
          _results.push(node);
        }
        return _results;
      })();
      return this.page.editableController.add(editableNodes);
    };

    Renderer.prototype.detachFromDom = function(snippetView) {
      snippetView.detach();
      return this;
    };

    Renderer.prototype.highlightSnippet = function(snippetView) {
      return snippetView.$html.addClass(docClass.snippetHighlight);
    };

    Renderer.prototype.removeSnippetHighlight = function(snippetView) {
      return snippetView.$html.removeClass(docClass.snippetHighlight);
    };

    Renderer.prototype.createInterfaceInjector = function(snippetOrContainer) {
      if (snippetOrContainer instanceof SnippetModel) {
        return this.createSnippetInterfaceInjector(snippetOrContainer);
      } else if (snippetOrContainer instanceof SnippetContainer) {
        return this.createSnippetContainerInterfaceInjector(snippetOrContainer);
      }
    };

    Renderer.prototype.createSnippetInterfaceInjector = function(model) {
      if (model.uiInjector === void 0) {
        return model.uiInjector = new InterfaceInjector({
          snippet: model,
          renderer: this
        });
      }
    };

    Renderer.prototype.createSnippetContainerInterfaceInjector = function(snippetContainer) {
      if (snippetContainer.uiInjector === void 0) {
        return snippetContainer.uiInjector = new InterfaceInjector({
          snippetContainer: snippetContainer,
          renderer: this
        });
      }
    };

    return Renderer;

  })();

  SnippetDrag = (function() {
    function SnippetDrag(_arg) {
      var page, snippet;
      snippet = _arg.snippet, page = _arg.page;
      this.snippet = snippet;
      this.page = page;
      this.$highlightedContainer = {};
      this.onStart = $.proxy(this.onStart, this);
      this.onDrag = $.proxy(this.onDrag, this);
      this.onDrop = $.proxy(this.onDrop, this);
      this.classAdded = [];
    }

    SnippetDrag.prototype.onStart = function() {
      this.$insertPreview = $("<div class='doc-drag-preview'>");
      this.page.$body.append(this.$insertPreview).css('cursor', 'pointer');
      return this.page.blurFocusedElement();
    };

    SnippetDrag.prototype.removeCssClasses = function() {
      var $html, _i, _len, _ref;
      _ref = this.classAdded;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        $html = _ref[_i];
        $html.removeClass(docClass.afterDrop).removeClass(docClass.beforeDrop);
      }
      return this.classAdded = [];
    };

    SnippetDrag.prototype.isValidTarget = function(target) {
      if (target.snippetView && target.snippetView.model !== this.snippet) {
        return true;
      } else if (target.containerName) {
        return true;
      }
      return false;
    };

    SnippetDrag.prototype.onDrag = function(target, drag, cursor) {
      var $container, coords, _base, _base1;
      if (!this.isValidTarget(target)) {
        $container = target = {};
      }
      if (target.containerName) {
        dom.maximizeContainerHeight(target.parent);
        $container = $(target.node);
      } else if (target.snippetView) {
        dom.maximizeContainerHeight(target.snippetView);
        $container = target.snippetView.get$container();
        $container.addClass(docClass.containerHighlight);
      } else {
        $container = target = {};
      }
      if ($container[0] !== this.$highlightedContainer[0]) {
        if (typeof (_base = this.$highlightedContainer).removeClass === "function") {
          _base.removeClass(docClass.containerHighlight);
        }
        this.$highlightedContainer = $container;
        if (typeof (_base1 = this.$highlightedContainer).addClass === "function") {
          _base1.addClass(docClass.containerHighlight);
        }
      }
      if (target.coords) {
        coords = target.coords;
        return this.$insertPreview.css({
          left: "" + coords.left + "px",
          top: "" + (coords.top - 5) + "px",
          width: "" + coords.width + "px"
        }).show();
      } else {
        return this.$insertPreview.hide();
      }
    };

    SnippetDrag.prototype.onDrop = function(drag) {
      var snippetView, target, _base;
      this.page.$body.css('cursor', '');
      this.$insertPreview.remove();
      if (typeof (_base = this.$highlightedContainer).removeClass === "function") {
        _base.removeClass(docClass.containerHighlight);
      }
      dom.restoreContainerHeight();
      target = drag.target;
      if (target && this.isValidTarget(target)) {
        if (snippetView = target.snippetView) {
          if (target.position === 'before') {
            return snippetView.model.before(this.snippet);
          } else {
            return snippetView.model.after(this.snippet);
          }
        } else if (target.containerName) {
          return target.parent.model.append(target.containerName, this.snippet);
        }
      } else {

      }
    };

    return SnippetDrag;

  })();

  SnippetSelection = (function() {
    function SnippetSelection() {
      this.snippets = [];
    }

    return SnippetSelection;

  })();

  SnippetView = (function() {
    function SnippetView(_arg) {
      this.model = _arg.model, this.$html = _arg.$html, this.editables = _arg.editables, this.containers = _arg.containers, this.images = _arg.images;
      this.template = this.model.template;
      this.attachedToDom = false;
      this.$html.data('snippet', this).addClass(docClass.snippet).attr(docAttr.template, this.template.identifier);
      this.updateContent();
    }

    SnippetView.prototype.updateContent = function() {
      return this.content(this.model.editables, this.model.images);
    };

    SnippetView.prototype.next = function() {
      return this.$html.next().data('snippet');
    };

    SnippetView.prototype.prev = function() {
      return this.$html.prev().data('snippet');
    };

    SnippetView.prototype.focus = function(cursor) {
      var first;
      first = this.firstEditableElem();
      return $(first).focus();
    };

    SnippetView.prototype.firstEditableElem = function() {
      var elem, _ref;
      _ref = this.editables;
      for (name in _ref) {
        elem = _ref[name];
        return elem;
      }
    };

    SnippetView.prototype.getBoundingClientRect = function() {
      return dom.getBoundingClientRect(this.$html[0]);
    };

    SnippetView.prototype.content = function(content, images) {
      var field, _results;
      for (field in content) {
        value = content[field];
        this.set(field, value);
      }
      _results = [];
      for (field in images) {
        value = images[field];
        _results.push(this.setImage(field, value));
      }
      return _results;
    };

    SnippetView.prototype.getEditable = function(name) {
      if (name != null) {
        return this.editables[name];
      } else {
        for (name in this.editables) {
          return this.editables[name];
        }
      }
    };

    SnippetView.prototype.setImage = function(name, value) {
      var elem;
      elem = this.images[name];
      return $(elem).attr('src', value);
    };

    SnippetView.prototype.set = function(editable, value) {
      var elem;
      if (arguments.length === 1) {
        value = editable;
        editable = void 0;
      }
      if (elem = this.getEditable(editable)) {
        return $(elem).html(value);
      } else {
        return log.error('cannot set value without editable name');
      }
    };

    SnippetView.prototype.get = function(editable) {
      var elem;
      if (elem = this.getEditable(editable)) {
        return $(elem).html();
      } else {
        return log.error('cannot get value without editable name');
      }
    };

    SnippetView.prototype.append = function(containerName, $elem) {
      var $container;
      $container = $(this.containers[containerName]);
      return $container.append($elem);
    };

    SnippetView.prototype.attach = function(renderer) {
      var next, nextHtml, parentContainer, previous, previousHtml;
      if (this.attachedToDom) {
        return;
      }
      previous = this.model.previous;
      next = this.model.next;
      parentContainer = this.model.parentContainer;
      if ((previous != null) && (previousHtml = renderer.getSnippetView(previous)) && previousHtml.attachedToDom) {
        previousHtml.$html.after(this.$html);
        this.attachedToDom = true;
      } else if ((next != null) && (nextHtml = renderer.getSnippetView(next)) && nextHtml.attachedToDom) {
        nextHtml.$html.before(this.$html);
        this.attachedToDom = true;
      } else if (parentContainer) {
        this.appendToContainer(parentContainer, renderer);
        this.attachedToDom = true;
      }
      return this;
    };

    SnippetView.prototype.appendToContainer = function(container, renderer) {
      var snippetView;
      if (container.isRoot) {
        return renderer.$root.append(this.$html);
      } else {
        snippetView = renderer.getSnippetView(container.parentSnippet);
        return snippetView.append(container.name, this.$html);
      }
    };

    SnippetView.prototype.detach = function() {
      this.attachedToDom = false;
      return this.$html.detach();
    };

    SnippetView.prototype.get$container = function() {
      return $(dom.findContainer(this.$html[0]).node);
    };

    return SnippetView;

  })();

  this.doc = function(search) {
    return document.find(search);
  };

  chainable = chainableProxy(doc);

  setupApi = function() {
    this.kickstart = chainable(kickstart, 'init');
    this.init = chainable(document, 'init');
    this.ready = chainable(document.ready, 'add');
    this.getDesign = function() {
      return document.design;
    };
    this.add = $.proxy(document, 'add');
    this.create = $.proxy(document, 'createModel');
    this.toJson = $.proxy(document, 'toJson');
    this.readableJson = function() {
      return words.readableJson(document.toJson());
    };
    this.printTree = $.proxy(document, 'printTree');
    this.eachContainer = chainable(document, 'eachContainer');
    this.document = document;
    this.changed = chainable(document.changed, 'add');
    this.DragDrop = DragDrop;
    stash.init();
    this.stash = $.proxy(stash, 'stash');
    this.stash.snapshot = $.proxy(stash, 'snapshot');
    this.stash["delete"] = $.proxy(stash, 'delete');
    this.stash.restore = $.proxy(stash, 'restore');
    this.stash.get = $.proxy(stash, 'get');
    this.stash.list = $.proxy(stash, 'list');
    this.words = words;
    return this.fn = SnippetArray.prototype;
  };

  pageReady = function() {
    var page;
    page = document.page;
    this.restore = chainable(document, 'restore');
    this.snippetFocused = chainable(page.focus.snippetFocus, 'add');
    this.snippetBlurred = chainable(page.focus.snippetBlur, 'add');
    this.startDrag = $.proxy(page, 'startDrag');
    this.imageClick = chainable(page.imageClick, 'add');
    return this.textSelection = chainable(page.editableController.selection, 'add');
  };

  setupApi.call(doc);

  doc.ready(function() {
    return pageReady.call(doc);
  });

}).call(this);

/*
//@ sourceMappingURL=livingdocs_engine.js.map
*/