(function() {
  var Design, DesignStyle, Directive, DirectiveCollection, DirectiveIterator, DragDrop, EditableController, Focus, History, HistoryAction, InterfaceInjector, LimitedLocalstore, Loader, ModelDirectives, Page, Renderer, SnippetArray, SnippetContainer, SnippetDrag, SnippetModel, SnippetSelection, SnippetTemplateList, SnippetTree, SnippetView, Template, assert, chainable, chainableProxy, directiveParser, document, dom, guid, htmlCompare, kickstart, localstore, log, mixins, pageReady, setupApi, stash,
    __slice = [].slice;

  (function() {
    var key, n, name, v, value, _ref, _ref1, _ref2, _results;
    this.config = {
      wordSeparators: "./\\()\"':,.;<>~!#%^&*|+=[]{}`~?",
      attributePrefix: 'data'
    };
    this.docClass = {
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
    this.templateAttr = {
      editable: 'doc-editable',
      container: 'doc-container',
      image: 'doc-image',
      defaultValues: {
        editable: 'default',
        container: 'default',
        image: 'image'
      }
    };
    this.templateAttrLookup = {};
    this.docAttr = {
      template: 'doc-template'
    };
    _ref = this.templateAttr;
    for (n in _ref) {
      v = _ref[n];
      this.templateAttrLookup[v] = n;
    }
    _ref1 = this.templateAttr;
    for (name in _ref1) {
      value = _ref1[name];
      this.docAttr[name] = value;
    }
    if (this.config.attributePrefix) {
      _ref2 = this.docAttr;
      _results = [];
      for (key in _ref2) {
        value = _ref2[key];
        _results.push(this.docAttr[key] = "" + config.attributePrefix + "-" + value);
      }
      return _results;
    }
  })();

  assert = function(condition, message) {
    if (!condition) {
      return log.error(message);
    }
  };

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
          var child, n;
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
      var index, reference, value;
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
      var index, reference, value;
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
      if (!log.debugDisabled) {
        return notify(message, 'debug');
      }
    };
    log.warn = function(message) {
      if (!log.warningsDisabled) {
        return notify(message, 'warning');
      }
    };
    return log.error = function(message) {
      return notify(message, 'error');
    };
  })();

  mixins = function() {
    var Mixed, method, mixin, mixins, name, _i;
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
        assert(json, 'stash is empty');
        return document.restore(json);
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

  ModelDirectives = (function() {
    function ModelDirectives(snippetModel, templateDirectives) {
      var directive, list, _i, _len;
      this.editables = this.images = this.containers = {
        length: 0
      };
      for (_i = 0, _len = templateDirectives.length; _i < _len; _i++) {
        directive = templateDirectives[_i];
        this.all[directive.name] = directive;
        list = (function() {
          switch (directive.type) {
            case 'editable':
              return this.editables;
            case 'image':
              return this.images;
            case 'container':
              return this.containers;
          }
        }).call(this);
        this.addDirective(list, directive, snippetModel);
      }
      ({
        addDirective: function(list, directive, snippetModel) {
          var listElem;
          listElem = directive;
          if (directive.type === 'container') {
            listElem = new SnippetContainer({
              name: directive.name,
              parentSnippet: snippetModel
            });
          }
          list[list.length] = listElem;
          list.length += 1;
          return this.length += 1;
        }
      });
    }

    return ModelDirectives;

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
      if (this.parentSnippet) {
        assert(snippet !== this.parentSnippet, 'cannot append snippet to itself');
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
      assert(snippet !== insertedSnippet, 'cannot insert snippet before itself');
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
      assert(snippet !== insertedSnippet, 'cannot insert snippet after itself');
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
        var name, snippetContainer, _ref, _results;
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
        var name, snippetContainer, _ref, _results;
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
      assert(this.template, 'cannot instantiate snippet without template reference');
      this.initializeDirectives();
      this.styles = {};
      this.id = id || guid.next();
      this.identifier = this.template.identifier;
      this.next = void 0;
      this.previous = void 0;
      this.snippetTree = void 0;
    }

    SnippetModel.prototype.initializeDirectives = function() {
      var directive, _i, _len, _ref, _results;
      _ref = this.template.directives;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        directive = _ref[_i];
        switch (directive.type) {
          case 'container':
            this.containers || (this.containers = {});
            _results.push(this.containers[directive.name] = new SnippetContainer({
              name: directive.name,
              parentSnippet: this
            }));
            break;
          case 'editable':
          case 'image':
            this.content || (this.content = {});
            _results.push(this.content[directive.name] = void 0);
            break;
          default:
            _results.push(log.error("Template directive type '" + directive.type + "' not implemented in SnippetModel"));
        }
      }
      return _results;
    };

    SnippetModel.prototype.hasContainers = function() {
      return this.template.directives.count('container') > 0;
    };

    SnippetModel.prototype.hasEditables = function() {
      return this.template.directives.count('editable') > 0;
    };

    SnippetModel.prototype.hasImages = function() {
      return this.template.directives.count('image') > 0;
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
      var _ref;
      if ((_ref = this.content) != null ? _ref.hasOwnProperty(name) : void 0) {
        if (this.content[name] !== value) {
          this.content[name] = value;
          if (this.snippetTree) {
            return this.snippetTree.contentChanging(this, name);
          }
        }
      } else {
        return log.error("set error: " + this.identifier + " has no content named " + name);
      }
    };

    SnippetModel.prototype.get = function(name) {
      var _ref;
      if ((_ref = this.content) != null ? _ref.hasOwnProperty(name) : void 0) {
        return this.content[name];
      } else {
        return log.error("get error: " + this.identifier + " has no name named " + name);
      }
    };

    SnippetModel.prototype.style = function(name, value) {
      if (arguments.length === 1) {
        return this.styles[name];
      } else {
        return this.setStyle(name, value);
      }
    };

    SnippetModel.prototype.setStyle = function(name, value) {
      var style;
      style = this.template.styles[name];
      if (!style) {
        return log.warn("Unknown style '" + name + "' in SnippetModel " + this.identifier);
      } else if (!style.validateValue(value)) {
        return log.warn("Invalid value '" + value + "' for style '" + name + "' in SnippetModel " + this.identifier);
      } else {
        if (this.styles[name] !== value) {
          this.styles[name] = value;
          if (this.snippetTree) {
            return this.snippetTree.htmlChanging(this, 'style', {
              name: name,
              value: value
            });
          }
        }
      }
    };

    SnippetModel.prototype.copy = function() {
      return log.warn("SnippetModel#copy() is not implemented yet.");
    };

    SnippetModel.prototype.copyWithoutContent = function() {
      return this.template.createModel();
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
      var name, snippetContainer, snippetModel, _ref, _results;
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
      var name, snippetContainer, snippetModel, _ref, _results;
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
        var name, snippetContainer, _ref, _results;
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
        var name, snippetContainer, _ref, _results;
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
      var json, name;
      json = {
        id: this.id,
        identifier: this.identifier
      };
      if (!this.isEmpty(this.content)) {
        json.content = this.flatCopy(this.content);
      }
      if (!this.isEmpty(this.styles)) {
        json.styles = this.flatCopy(this.styles);
      }
      for (name in this.containers) {
        json.containers || (json.containers = {});
        json.containers[name] = [];
      }
      return json;
    };

    SnippetModel.prototype.isEmpty = function(obj) {
      var name;
      if (obj == null) {
        return true;
      }
      for (name in obj) {
        if (obj.hasOwnProperty(name)) {
          return false;
        }
      }
      return true;
    };

    SnippetModel.prototype.flatCopy = function(obj) {
      var copy, name, value;
      copy = void 0;
      for (name in obj) {
        value = obj[name];
        copy || (copy = {});
        copy[name] = value;
      }
      return copy;
    };

    return SnippetModel;

  })();

  SnippetModel.fromJson = function(json, design) {
    var child, containerName, model, name, snippetArray, styleName, template, value, _i, _len, _ref, _ref1, _ref2;
    template = design.get(json.identifier);
    assert(template, "error while deserializing snippet: unknown template identifier '" + json.identifier + "'");
    model = new SnippetModel({
      template: template,
      id: json.id
    });
    _ref = json.content;
    for (name in _ref) {
      value = _ref[name];
      if (model.content.hasOwnProperty(name)) {
        model.content[name] = value;
      } else {
        log.error("error while deserializing snippet: unknown content '" + name + "'");
      }
    }
    _ref1 = json.styles;
    for (styleName in _ref1) {
      value = _ref1[styleName];
      model.style(styleName, value);
    }
    _ref2 = json.containers;
    for (containerName in _ref2) {
      snippetArray = _ref2[containerName];
      assert(model.containers.hasOwnProperty(containerName), "error while deserializing snippet: unknown container " + containerName);
      if (snippetArray) {
        assert($.isArray(snippetArray), "error while deserializing snippet: container is not array " + containerName);
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
        var name, snippetContainer, template, _ref;
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
      assert(snippet.snippetTree === this, 'cannot remove snippet from another SnippetTree');
      snippet.descendantsAndSelf(function(descendants) {
        return descendants.snippetTree = void 0;
      });
      detachSnippetFunc();
      return this.fireEvent('snippetRemoved', snippet);
    };

    SnippetTree.prototype.contentChanging = function(snippet) {
      return this.fireEvent('snippetContentChanged', snippet);
    };

    SnippetTree.prototype.htmlChanging = function(snippet) {
      return this.fireEvent('snippetHtmlChanged', snippet);
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
        var containerArray, name, snippetContainer, snippetJson, _ref;
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

  Directive = (function() {
    function Directive(_arg) {
      var name;
      name = _arg.name, this.type = _arg.type, this.elem = _arg.elem;
      this.name = name || templateAttr.defaultValues[this.type];
    }

    return Directive;

  })();

  DirectiveCollection = (function() {
    function DirectiveCollection(all) {
      this.all = all != null ? all : {};
      this.length = 0;
    }

    DirectiveCollection.prototype.add = function(directive) {
      var _name;
      this.assertNameNotUsed(directive);
      this[this.length] = directive;
      directive.index = this.length;
      this.length += 1;
      this.all[directive.name] = directive;
      this[_name = directive.type] || (this[_name] = []);
      return this[directive.type].push(directive);
    };

    DirectiveCollection.prototype.next = function(name) {
      var directive;
      if (name instanceof Directive) {
        directive = name;
      }
      directive || (directive = this.all[name]);
      return this[directive.index += 1];
    };

    DirectiveCollection.prototype.nextOfType = function(name) {
      var directive, requiredType;
      if (name instanceof Directive) {
        directive = name;
      }
      directive || (directive = this.all[name]);
      requiredType = directive.type;
      while (directive = this.next(directive)) {
        if (directive.type === requiredType) {
          return directive;
        }
      }
    };

    DirectiveCollection.prototype.get = function(name) {
      return this.all[name];
    };

    DirectiveCollection.prototype.count = function(type) {
      var _ref;
      if (type) {
        return (_ref = this[type]) != null ? _ref.length : void 0;
      } else {
        return this.length;
      }
    };

    DirectiveCollection.prototype.assertNameNotUsed = function(directive) {
      if (this.all[directive.name]) {
        return log.error("" + directive.type + " Template parsing error:\n" + docAttr[directive.type] + "=\"" + directive.name + "\".\n\"" + directive.name + "\" is a duplicate name.");
      }
    };

    return DirectiveCollection;

  })();

  DirectiveIterator = (function() {
    function DirectiveIterator(root) {
      this.root = this._next = root;
    }

    DirectiveIterator.prototype.current = null;

    DirectiveIterator.prototype.hasNext = function() {
      return !!this._next;
    };

    DirectiveIterator.prototype.next = function() {
      var child, n, next;
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

    DirectiveIterator.prototype.nextElement = function() {
      while (this.next()) {
        if (this.current.nodeType === 1) {
          break;
        }
      }
      return this.current;
    };

    DirectiveIterator.prototype.detach = function() {
      return this.current = this._next = this.root = null;
    };

    return DirectiveIterator;

  })();

  directiveParser = (function() {
    var attributePrefix;
    attributePrefix = /^(x-|data-)/;
    return {
      parse: function(elem) {
        var attr, attributeName, directive, normalizedName, type, _i, _len, _ref;
        directive = void 0;
        _ref = elem.attributes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          attr = _ref[_i];
          attributeName = attr.name;
          normalizedName = attributeName.replace(attributePrefix, '');
          if (type = templateAttrLookup[normalizedName]) {
            directive = new Directive({
              name: attr.value,
              type: type,
              elem: elem
            });
            if (attributeName !== docAttr[type]) {
              this.normalizeAttribute(directive, attributeName);
            } else if (!attr.value) {
              this.normalizeAttribute(directive);
            }
          }
        }
        return directive;
      },
      normalizeAttribute: function(directive, attributeName) {
        var elem;
        elem = directive.elem;
        if (attributeName) {
          elem.removeAttribute(attributeName);
        }
        return elem.setAttribute(docAttr[directive.type], directive.name);
      }
    };
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
      assert(html, 'Template: param html missing');
      if (identifier) {
        _ref1 = Template.parseIdentifier(identifier), this.namespace = _ref1.namespace, this.id = _ref1.id;
      }
      this.identifier = this.namespace && this.id ? "" + this.namespace + "." + this.id : void 0;
      this.version = version || 1;
      this.$template = $(this.pruneHtml(html)).wrap('<div>');
      this.$wrap = this.$template.parent();
      this.title = title || words.humanize(this.id);
      this.styles = styles || {};
      this.weight = weight;
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
      var $elem, directives, snippetView;
      snippetModel || (snippetModel = this.createModel());
      $elem = this.$template.clone();
      directives = this.getDirectives($elem[0]);
      return snippetView = new SnippetView({
        model: snippetModel,
        $html: $elem,
        directives: directives
      });
    };

    Template.prototype.pruneHtml = function(html) {
      html = $(html).filter(function(index) {
        return this.nodeType !== 8;
      });
      assert(html.length === 1, "Templates must contain one root element. The Template \"" + this.identifier + "\" contains " + html.length);
      return html;
    };

    Template.prototype.parseTemplate = function() {
      var containers, directive, editables, elem, _i, _j, _len, _len1, _results;
      elem = this.$template[0];
      this.directives = this.getDirectives(elem);
      if (editables = this.directives.editable) {
        for (_i = 0, _len = editables.length; _i < _len; _i++) {
          directive = editables[_i];
          this.formatEditable(directive.name, directive.elem);
        }
      }
      if (containers = this.directives.container) {
        _results = [];
        for (_j = 0, _len1 = containers.length; _j < _len1; _j++) {
          directive = containers[_j];
          _results.push(this.formatContainer(directive.name, directive.elem));
        }
        return _results;
      }
    };

    Template.prototype.getDirectives = function(elem) {
      var directive, directives, iterator;
      iterator = new DirectiveIterator(elem);
      directives = new DirectiveCollection();
      while (elem = iterator.nextElement()) {
        directive = directiveParser.parse(elem);
        if (directive) {
          directives.add(directive);
        }
      }
      return directives;
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
        identifier: this.identifier
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
      var config, groups, templates;
      templates = design.templates || design.snippets;
      config = design.config;
      groups = design.config.groups || design.groups;
      this.namespace = (config != null ? config.namespace : void 0) || 'livingdocs-templates';
      this.css = config.css;
      this.js = config.js;
      this.fonts = config.fonts;
      this.templates = [];
      this.groups = {};
      this.styles = {};
      this.storeTemplateDefinitions(templates);
      this.globalStyles = this.createDesignStyleCollection(design.config.styles);
      this.addGroups(groups);
      this.addTemplatesNotInGroups();
    }

    Design.prototype.storeTemplateDefinitions = function(templates) {
      var template, _i, _len, _results;
      this.templateDefinitions = {};
      _results = [];
      for (_i = 0, _len = templates.length; _i < _len; _i++) {
        template = templates[_i];
        _results.push(this.templateDefinitions[template.id] = template);
      }
      return _results;
    };

    Design.prototype.add = function(templateDefinition, styles) {
      var template, templateOnlyStyles, templateStyles;
      this.templateDefinitions[templateDefinition.id] = void 0;
      templateOnlyStyles = this.createDesignStyleCollection(templateDefinition.styles);
      templateStyles = $.extend({}, styles, templateOnlyStyles);
      template = new Template({
        namespace: this.namespace,
        id: templateDefinition.id,
        title: templateDefinition.title,
        styles: templateStyles,
        html: templateDefinition.html,
        weight: templateDefinition.sortOrder || 0
      });
      this.templates.push(template);
      return template;
    };

    Design.prototype.addGroups = function(collection) {
      var group, groupName, groupOnlyStyles, groupStyles, template, templateDefinition, templateId, templates, _i, _len, _ref, _results;
      _results = [];
      for (groupName in collection) {
        group = collection[groupName];
        groupOnlyStyles = this.createDesignStyleCollection(group.styles);
        groupStyles = $.extend({}, this.globalStyles, groupOnlyStyles);
        templates = {};
        _ref = group.templates;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          templateId = _ref[_i];
          templateDefinition = this.templateDefinitions[templateId];
          template = this.add(templateDefinition, groupStyles);
          templates[template.id] = template;
        }
        _results.push(this.addGroup(groupName, group, templates));
      }
      return _results;
    };

    Design.prototype.addTemplatesNotInGroups = function(globalStyles) {
      var templateDefinition, templateId, _ref, _results;
      _ref = this.templateDefinitions;
      _results = [];
      for (templateId in _ref) {
        templateDefinition = _ref[templateId];
        if (templateDefinition) {
          _results.push(this.add(templateDefinition, this.globalStyles));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Design.prototype.addGroup = function(name, group, templates) {
      return this.groups[name] = {
        title: group.title,
        templates: templates
      };
    };

    Design.prototype.createDesignStyleCollection = function(styles) {
      var designStyle, designStyles, styleDefinition, _i, _len;
      designStyles = {};
      if (styles) {
        for (_i = 0, _len = styles.length; _i < _len; _i++) {
          styleDefinition = styles[_i];
          designStyle = this.createDesignStyle(styleDefinition);
          if (designStyle) {
            designStyles[designStyle.name] = designStyle;
          }
        }
      }
      return designStyles;
    };

    Design.prototype.createDesignStyle = function(styleDefinition) {
      if (styleDefinition && styleDefinition.name) {
        return new DesignStyle({
          name: styleDefinition.name,
          type: styleDefinition.type,
          options: styleDefinition.options,
          value: styleDefinition.value
        });
      }
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
      assert(!namespace || this.namespace === namespace, "design " + this.namespace + ": cannot get template with different namespace " + namespace + " ");
      return callback(id);
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

  DesignStyle = (function() {
    function DesignStyle(_arg) {
      var options, value;
      this.name = _arg.name, this.type = _arg.type, value = _arg.value, options = _arg.options;
      switch (this.type) {
        case 'option':
          assert(value, "TemplateStyle error: no 'value' provided");
          this.value = value;
          break;
        case 'select':
          assert(options, "TemplateStyle error: no 'options' provided");
          this.options = options;
          break;
        default:
          log.error("TemplateStyle error: unknown type '" + this.type + "'");
      }
    }

    DesignStyle.prototype.cssClassChanges = function(value) {
      if (this.validateValue(value)) {
        if (this.type === 'option') {
          return {
            remove: !value ? [this.value] : void 0,
            add: value
          };
        } else if (this.type === 'select') {
          return {
            remove: this.otherClasses(value),
            add: value
          };
        }
      } else {
        if (this.type === 'option') {
          return {
            remove: currentValue,
            add: void 0
          };
        } else if (this.type === 'select') {
          return {
            remove: this.otherClasses(void 0),
            add: void 0
          };
        }
      }
    };

    DesignStyle.prototype.validateValue = function(value) {
      if (!value) {
        return true;
      } else if (this.type === 'option') {
        return value === this.value;
      } else if (this.type === 'select') {
        return this.containsOption(value);
      } else {
        return log.warn("Not implemented: DesignStyle#validateValue() for type " + this.type);
      }
    };

    DesignStyle.prototype.containsOption = function(value) {
      var option, _i, _len, _ref;
      _ref = this.options;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        option = _ref[_i];
        if (value === option.value) {
          return true;
        }
      }
      return false;
    };

    DesignStyle.prototype.otherOptions = function(value) {
      var option, others, _i, _len, _ref;
      others = [];
      _ref = this.options;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        option = _ref[_i];
        if (option.value !== value) {
          others.push(option);
        }
      }
      return others;
    };

    DesignStyle.prototype.otherClasses = function(value) {
      var option, others, _i, _len, _ref;
      others = [];
      _ref = this.options;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        option = _ref[_i];
        if (option.value !== value) {
          others.push(option.value);
        }
      }
      return others;
    };

    return DesignStyle;

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
        assert(!this.initialized, 'document is already initialized');
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
        assert(template, "could not find template " + identifier);
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
        var $elem, $parent, elem, name, outer, parentHeight, _ref, _results;
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
      this.page = page;
      Editable.init({
        log: false
      });
      this.selection = $.Callbacks();
      Editable.focus($.proxy(this.focus, this)).blur($.proxy(this.blur, this)).insert($.proxy(this.insert, this)).merge($.proxy(this.merge, this)).split($.proxy(this.split, this)).selection($.proxy(this.selectionChanged, this));
    }

    EditableController.prototype.add = function(nodes) {
      return Editable.add(nodes);
    };

    EditableController.prototype.disableAll = function() {
      return $('[contenteditable]').attr('contenteditable', 'false');
    };

    EditableController.prototype.reenableAll = function() {
      return $('[contenteditable]').attr('contenteditable', 'true');
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
      var afterContent, beforeContent, copy, editableName, view;
      view = dom.findSnippetView(element);
      if (view.model.editableCount === 1) {
        copy = view.template.createModel();
        beforeContent = before.querySelector('*').innerHTML;
        afterContent = after.querySelector('*').innerHTML;
        editableName = Object.keys(view.template.editables)[0];
        view.model.set(editableName, beforeContent);
        copy.set(editableName, afterContent);
        view.model.after(copy);
        view.next().focus();
      }
      return false;
    };

    EditableController.prototype.selectionChanged = function(element, selection) {
      var snippetView;
      snippetView = dom.findSnippetView(element);
      return this.selection.fire(snippetView, element, selection);
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
      if (this.snippet) {
        assert((_ref = this.snippet.snippetView) != null ? _ref.attachedToDom : void 0, 'snippet is not attached to the DOM');
      }
      if (this.snippetContainer) {
        if (!this.snippetContainer.isRoot && !((_ref1 = this.snippetContainer.parentSnippet) != null ? (_ref2 = _ref1.snippetView) != null ? _ref2.attachedToDom : void 0 : void 0)) {
          log.error('snippetContainer is not attached to the DOM');
        }
      }
    }

    InterfaceInjector.prototype.before = function($elem) {
      assert(this.snippet, 'cannot use before on a snippetContainer');
      this.beforeInjecting($elem);
      return this.snippet.snippetView.$html.before($elem);
    };

    InterfaceInjector.prototype.after = function($elem) {
      assert(this.snippet, 'cannot use after on a snippetContainer');
      this.beforeInjecting($elem);
      return this.snippet.snippetView.$html.after($elem);
    };

    InterfaceInjector.prototype.append = function($elem) {
      assert(this.snippetContainer, 'cannot use append on a snippet');
      this.beforeInjecting($elem);
      return this.renderer.appendToContainer(this.snippetContainer, $elem);
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
          return domElements.each(function(index, element) {
            var row;
            row = doc.add(_this.nodeToSnippetName(element));
            return _this.setChildren(row, element);
          });
        });
      },
      parseContainers: function(snippet, data) {
        var child, containers, editableContainer, _i, _j, _len, _len1, _ref, _ref1, _results;
        containers = snippet.containers ? Object.keys(snippet.containers) : [];
        if (containers.length === 1 && containers.indexOf('default') !== -1 && !$(data).children('default').length) {
          _ref = $(data).children();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            child = _ref[_i];
            this.parseSnippets(snippet, 'default', child);
          }
        }
        _ref1 = $(containers.join(','), data);
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          editableContainer = _ref1[_j];
          _results.push((function() {
            var _k, _len2, _ref2, _results1;
            _ref2 = $(editableContainer).children();
            _results1 = [];
            for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
              child = _ref2[_k];
              _results1.push(this.parseSnippets(snippet, editableContainer.localName, child));
            }
            return _results1;
          }).call(this));
        }
        return _results;
      },
      parseSnippets: function(parentContainer, region, data) {
        var snippet;
        snippet = doc.create(this.nodeToSnippetName(data));
        parentContainer.append(region, snippet);
        return this.setChildren(snippet, data);
      },
      setChildren: function(snippet, data) {
        this.parseContainers(snippet, data);
        return this.setEditables(snippet, data);
      },
      setEditables: function(snippet, data) {
        var child, directive, key, _results;
        _results = [];
        for (key in snippet.content) {
          directive = snippet.template.directives.get(key);
          snippet.set(key, null);
          child = $(key, data).get()[0];
          if (key === 'image' && !child) {
            child = $('img', data).get()[0];
          }
          if (!child) {
            log('The snippet "' + key + '" has no content. Display parent HTML instead.');
            child = data;
          }
          _results.push(snippet.set(key, child.innerHTML));
        }
        return _results;
      },
      nodeToSnippetName: function(element) {
        var snippet, snippetName;
        snippetName = $.camelCase(element.localName);
        snippet = doc.document.design.get(snippetName);
        if (snippetName === 'img' && !snippet) {
          snippetName = 'image';
          snippet = doc.document.design.get('image');
        }
        assert(snippet, "The Template named '" + snippetName + "' does not exist.");
        return snippetName;
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
      assert($root.length, 'no rootNode found');
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
      assert(this.snippetTree, 'no snippet tree specified');
      assert(rootNode, 'no root node specified');
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
      this.snippetTree.snippetContentChanged.add($.proxy(this, 'snippetContentChanged'));
      return this.snippetTree.snippetHtmlChanged.add($.proxy(this, 'snippetHtmlChanged'));
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

    Renderer.prototype.snippetHtmlChanged = function(model) {
      var view;
      view = this.ensureSnippetView(model);
      if (!view.attachedToDom) {
        this.insertIntoDom(view);
      }
      return view.updateHtml();
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
      assert(snippetView.attachedToDom, 'could not insert snippet into Dom');
      this.afterDomInsert(snippetView);
      return this;
    };

    Renderer.prototype.afterDomInsert = function(snippetView) {
      return this.initializeEditables(snippetView);
    };

    Renderer.prototype.initializeEditables = function(snippetView) {
      var directive, editableNodes;
      if (snippetView.directives.editable) {
        editableNodes = (function() {
          var _i, _len, _ref, _results;
          _ref = snippetView.directives.editable;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            directive = _ref[_i];
            _results.push(directive.elem);
          }
          return _results;
        })();
      }
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
      this.page.editableController.disableAll();
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
      this.page.editableController.reenableAll();
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
      this.model = _arg.model, this.$html = _arg.$html, this.directives = _arg.directives;
      this.template = this.model.template;
      this.attachedToDom = false;
      this.wasAttachedToDom = $.Callbacks();
      this.$html.data('snippet', this).addClass(docClass.snippet).attr(docAttr.template, this.template.identifier);
      this.updateContent();
      this.updateHtml();
    }

    SnippetView.prototype.updateContent = function() {
      return this.content(this.model.content);
    };

    SnippetView.prototype.updateHtml = function() {
      var name, value, _ref, _results;
      _ref = this.model.styles;
      _results = [];
      for (name in _ref) {
        value = _ref[name];
        _results.push(this.style(name, value));
      }
      return _results;
    };

    SnippetView.prototype.next = function() {
      return this.$html.next().data('snippet');
    };

    SnippetView.prototype.prev = function() {
      return this.$html.prev().data('snippet');
    };

    SnippetView.prototype.focus = function(cursor) {
      var first, _ref;
      first = (_ref = this.directives.editable) != null ? _ref[0].elem : void 0;
      return $(first).focus();
    };

    SnippetView.prototype.getBoundingClientRect = function() {
      return dom.getBoundingClientRect(this.$html[0]);
    };

    SnippetView.prototype.content = function(content) {
      var name, value, _results;
      _results = [];
      for (name in content) {
        value = content[name];
        _results.push(this.set(name, value));
      }
      return _results;
    };

    SnippetView.prototype.set = function(name, value) {
      var directive;
      directive = this.directives.get(name);
      switch (directive.type) {
        case 'editable':
          return this.setEditable(name, value);
        case 'image':
          return this.setImage(name, value);
      }
    };

    SnippetView.prototype.get = function(name) {
      var directive;
      directive = this.directives.get(name);
      switch (directive.type) {
        case 'editable':
          return this.getEditable(name);
        case 'image':
          return this.getImage(name);
      }
    };

    SnippetView.prototype.getEditable = function(name) {
      var elem;
      elem = this.directives.get(name).elem;
      return $(elem).html();
    };

    SnippetView.prototype.setEditable = function(name, value) {
      var elem;
      elem = this.directives.get(name).elem;
      return $(elem).html(value);
    };

    SnippetView.prototype.getImage = function(name) {
      var elem;
      elem = this.directives.get(name).elem;
      return $(elem).attr('src');
    };

    SnippetView.prototype.setImage = function(name, value) {
      var $elem, elem;
      elem = this.directives.get(name).elem;
      $elem = $(elem);
      if (value) {
        return this.setImageAttribute($elem, value);
      } else {
        if (this.attachedToDom) {
          return this.setPlaceholderImage($elem);
        } else {
          return this.wasAttachedToDom.add($.proxy(this.setPlaceholderImage, this, $elem));
        }
      }
    };

    SnippetView.prototype.setImageAttribute = function($elem, value) {
      if ($elem.context.tagName === 'IMG') {
        return $elem.attr('src', value);
      } else {
        return $elem.attr('style', "background-image:url(" + value + ")");
      }
    };

    SnippetView.prototype.setPlaceholderImage = function($elem) {
      var height, value, width;
      if ($elem.context.tagName === 'IMG') {
        width = $elem.width();
        height = $elem.height();
      } else {
        width = $elem.outerWidth();
        height = $elem.outerHeight();
      }
      value = "http://placehold.it/" + width + "x" + height + "/BEF56F/B2E668";
      return this.setImageAttribute($elem, value);
    };

    SnippetView.prototype.style = function(name, className) {
      var changes, removeClass, _i, _len, _ref;
      changes = this.template.styles[name].cssClassChanges(className);
      if (changes.remove) {
        _ref = changes.remove;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          removeClass = _ref[_i];
          this.$html.removeClass(removeClass);
        }
      }
      return this.$html.addClass(changes.add);
    };

    SnippetView.prototype.append = function(containerName, $elem) {
      var $container, _ref;
      $container = $((_ref = this.directives.get(containerName)) != null ? _ref.elem : void 0);
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
      this.wasAttachedToDom.fire();
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
    this.snippetAdded = chainable(document.snippetTree.snippetAdded, 'add');
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