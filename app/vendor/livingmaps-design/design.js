(function() { this.design || (this.design = {}); design.livingmaps = (function() { return {
  "config": {
    "namespace": "livingmaps",
    "version": 1,
    "css": [
      "/designs/livingmaps/css/style.css"
    ],
    "groups": {
      "layout": {
        "title": "Layout",
        "templates": [
          "column",
          "mainAndSidebar"
        ]
      },
      "others": {
        "title": "others",
        "templates": [
          "button",
          "hero",
          "image",
          "info",
          "largeButton",
          "map",
          "seperator",
          "smallSubtitle",
          "subtitle",
          "text",
          "title"
        ]
      }
    }
  },
  "templates": [
    {
      "title": "Single Centered Column",
      "id": "column",
      "html": "<div class=\"row-fluid\">\n  <div class=\"span8 offset2\" doc-container=\"\"></div>\n</div>"
    },
    {
      "title": "Main and Sidebar Columns",
      "id": "mainAndSidebar",
      "html": "<div class=\"row-fluid\">\n  <div class=\"span8\" doc-container=\"main\"></div>\n  <div class=\"span4\" doc-container=\"sidebar\"></div>\n</div>"
    },
    {
      "title": "Button",
      "id": "button",
      "html": "<button class=\"btn\" type=\"button\" doc-editable=\"button\">Button</button>"
    },
    {
      "title": "Hero",
      "id": "hero",
      "html": "<div class=\"hero-unit\">\n  <h1 doc-editable=\"title\">Titel</h1>\n  <p doc-editable=\"tagline\">Tagline</p>\n</div>"
    },
    {
      "title": "Image",
      "id": "image",
      "html": "<div class=\"img-polaroid\" doc-editable=\"image\">\n  Drag your image here...\n</div>"
    },
    {
      "title": "Info",
      "id": "info",
      "html": "<div class=\"alert alert-info\" doc-editable=\"info\">\n  Lorem Ipsum dolorem\n</div>"
    },
    {
      "title": "Large Button",
      "id": "largeButton",
      "html": "<div>\n  <hr>\n</div>"
    },
    {
      "title": "Map",
      "id": "map",
      "html": "<div data-type=\"angular-directive\">\n  <h3 doc-editable=\"title\">Title</h3>\n  <div data-placeholder=\"leaflet-directive\">\n    <iframe style=\"width: 100%\" frameborder=\"0\" scrolling=\"no\" marginheight=\"0\" marginwidth=\"0\" src=\"https://maps.google.ch/maps?hl=de&amp;ie=UTF8&amp;ll=46.362093,9.036255&amp;spn=8.279854,10.612793&amp;t=h&amp;z=7&amp;output=embed\"></iframe>\n  </div>\n</div>"
    },
    {
      "title": "Seperator",
      "id": "seperator",
      "html": "<div>\n  <hr>\n</div>"
    },
    {
      "title": "Paragraph Title",
      "id": "smallSubtitle",
      "html": "<h3 doc-editable=\"title\">Lorem ipsum dolorem</h3>"
    },
    {
      "title": "Subtitle",
      "id": "subtitle",
      "html": "<h2 doc-editable=\"title\">Subtitle</h2>"
    },
    {
      "title": "Text",
      "id": "text",
      "html": "<p doc-editable=\"text\">\n  Lorem ipsum dolorem. Lorem ipsum dolorem. Lorem ipsum dolorem\n</p>"
    },
    {
      "title": "Title",
      "id": "title",
      "html": "<h1 doc-editable=\"title\">Titel</h1>"
    }
  ]
};})();}).call(this);