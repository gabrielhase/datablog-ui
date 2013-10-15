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
      "maps": {
        "title": "maps",
        "templates": [
          "choropleth",
          "map",
          "unemploymentChoropleth"
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
      "html": "<div class=\"row-fluid\"><div class=\"span12\" doc-container=\"\"></div></div>"
    },
    {
      "title": "Main and Sidebar Columns",
      "id": "mainAndSidebar",
      "html": "<div class=\"row-fluid\"><div class=\"span8\" doc-container=\"main\"></div><div class=\"span4\" doc-container=\"sidebar\"></div></div>"
    },
    {
      "title": "Choropleth",
      "id": "choropleth",
      "html": "<div data-template=\"\"><h3 doc-editable=\"title\" doc-optional=\"\">Title</h3><div data-is=\"d3-choropleth\" data-dependency=\"d3\" data-dependency-resources=\"http://d3js.org/d3.v3.min.js\"><p>Couldn't load d3.js dependency. Maybe the service is down?</p></div><p class=\"source\" doc-editable=\"source\" doc-optional=\"\">Quelle</p></div>"
    },
    {
      "title": "Map",
      "id": "map",
      "html": "<div data-template=\"\"><h3 doc-editable=\"title\">Title</h3><div data-is=\"leaflet-map\" data-dependency=\"L\" data-dependency-resources=\"http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.js;http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.css\"><iframe style=\"width: 100%\" frameborder=\"0\" scrolling=\"no\" marginheight=\"0\" marginwidth=\"0\" src=\"https://maps.google.ch/maps?hl=de&amp;ie=UTF8&amp;ll=46.362093,9.036255&amp;spn=8.279854,10.612793&amp;t=h&amp;z=7&amp;output=embed\"></iframe></div></div>"
    },
    {
      "title": "UnemploymentChoropleth",
      "id": "unemploymentChoropleth",
      "html": "<div data-template=\"\"><h3 doc-editable=\"title\">Title</h3><div data-is=\"d3-choropleth\" data-dependency=\"d3\" data-dependency-resources=\"http://d3js.org/d3.v3.min.js\"><p>Couldn't load d3.js dependency. Maybe the service is down?</p></div></div>"
    },
    {
      "title": "Button",
      "id": "button",
      "html": "<button class=\"btn\" type=\"button\" doc-editable=\"button\">Button</button>"
    },
    {
      "title": "Hero",
      "id": "hero",
      "html": "<div class=\"hero-unit\"><h1 doc-editable=\"title\">Titel</h1><p doc-editable=\"tagline\">Tagline</p></div>"
    },
    {
      "title": "Image",
      "id": "image",
      "html": "<img class=\"img-polaroid img-full-width\" doc-image=\"image\" src=\"\">"
    },
    {
      "title": "Info",
      "id": "info",
      "html": "<div class=\"alert alert-info\" doc-editable=\"info\">Lorem Ipsum dolorem</div>"
    },
    {
      "title": "Large Button",
      "id": "largeButton",
      "html": "<div><hr></div>"
    },
    {
      "title": "Seperator",
      "id": "seperator",
      "html": "<div><hr></div>"
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
      "html": "<p doc-editable=\"text\">Lorem ipsum dolorem. Lorem ipsum dolorem. Lorem ipsum dolorem</p>"
    },
    {
      "title": "Title",
      "id": "title",
      "html": "<h1 doc-editable=\"title\">Titel</h1>"
    }
  ],
  "kickstarters": []
};})();}).call(this);