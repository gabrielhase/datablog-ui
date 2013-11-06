(function() { this.design || (this.design = {}); design.livingmaps = (function() { return {
  "config": {
    "namespace": "livingmaps",
    "version": 1,
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
      "id": "column",
      "title": "column",
      "html": "<div class=\"row-fluid\"><div class=\"span12\" doc-container=\"\"></div></div>"
    },
    {
      "id": "mainAndSidebar",
      "title": "mainAndSidebar",
      "html": "<div class=\"row-fluid\"><div class=\"span8\" doc-container=\"main\"></div><div class=\"span4\" doc-container=\"sidebar\"></div></div>"
    },
    {
      "id": "choropleth",
      "title": "choropleth",
      "html": "<div data-template=\"\"><h3 doc-editable=\"title\" doc-optional=\"\">Title</h3><div data-is=\"d3-choropleth\" data-dependency=\"d3\" data-dependency-resources=\"http://d3js.org/d3.v3.min.js;https://s3.amazonaws.com/datablog-assets/color_brewer.css;\"><p>Couldn't load d3.js dependency. Maybe the service is down?</p></div><p class=\"source\" doc-editable=\"source\" doc-optional=\"\">Quelle</p></div>"
    },
    {
      "id": "map",
      "title": "map",
      "html": "<div data-template=\"\"><h3 doc-editable=\"title\">Title</h3><div data-is=\"leaflet-map\" data-dependency=\"L\" data-dependency-resources=\"http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.js;http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.css\"><iframe style=\"width: 100%\" frameborder=\"0\" scrolling=\"no\" marginheight=\"0\" marginwidth=\"0\" src=\"https://maps.google.ch/maps?hl=de&amp;ie=UTF8&amp;ll=46.362093,9.036255&amp;spn=8.279854,10.612793&amp;t=h&amp;z=7&amp;output=embed\"></iframe></div></div>"
    },
    {
      "id": "unemploymentChoropleth",
      "title": "unemploymentChoropleth",
      "html": "<div data-template=\"\"><h3 doc-editable=\"title\">Title</h3><div data-is=\"d3-choropleth\" data-dependency=\"d3\" data-dependency-resources=\"http://d3js.org/d3.v3.min.js;https://s3.amazonaws.com/datablog-assets/color_brewer.css\"><p>Couldn't load d3.js dependency. Maybe the service is down?</p></div></div>"
    },
    {
      "id": "button",
      "title": "button",
      "html": "<button class=\"btn\" type=\"button\" doc-editable=\"button\">Button</button>"
    },
    {
      "id": "hero",
      "title": "hero",
      "html": "<div class=\"hero-unit\"><h1 doc-editable=\"title\">Titel</h1><p doc-editable=\"tagline\">Tagline</p></div>"
    },
    {
      "id": "image",
      "title": "image",
      "html": "<img class=\"img-polaroid img-full-width\" doc-image=\"image\" src=\"\">"
    },
    {
      "id": "info",
      "title": "info",
      "html": "<div class=\"alert alert-info\" doc-editable=\"info\">Lorem Ipsum dolorem</div>"
    },
    {
      "id": "largeButton",
      "title": "largeButton",
      "html": "<div><hr></div>"
    },
    {
      "id": "seperator",
      "title": "seperator",
      "html": "<div><hr></div>"
    },
    {
      "id": "smallSubtitle",
      "title": "smallSubtitle",
      "html": "<h3 doc-editable=\"title\">Lorem ipsum dolorem</h3>"
    },
    {
      "id": "subtitle",
      "title": "subtitle",
      "html": "<h2 doc-editable=\"title\">Subtitle</h2>"
    },
    {
      "id": "text",
      "title": "text",
      "html": "<p doc-editable=\"text\">Lorem ipsum dolorem. Lorem ipsum dolorem. Lorem ipsum dolorem</p>"
    },
    {
      "id": "title",
      "title": "title",
      "html": "<h1 doc-editable=\"title\">Titel</h1>"
    }
  ],
  "kickstarters": [
    {
      "name": "Livingmaps",
      "markup": "\n    <hero>\n      <title>Snippet outside container</title>\n      <tagline>Yep, it works</tagline>\n    </hero>\n\n    <column>\n        <main-and-sidebar>\n          <main>\n            <map is=\"leaflet-map\">\n              An example map\n            </map>\n          </main>\n          <sidebar>\n            <text>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto, a, quam non nobis suscipit nostrum nam modi ducimus voluptate distinctio! Quam, libero, nobis suscipit autem molestias labore officia natus in.</text>\n            <text>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Laboriosam, unde, veniam, reprehenderit ipsum blanditiis minima obcaecati modi assumenda eius sapiente nihil cupiditate voluptatum ut ipsa quo harum atque doloribus iste!</text>\n          </sidebar>\n        </main-and-sidebar>\n\n        <text>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Minima, rerum, maiores nobis vero iure dolorem quisquam excepturi ipsam a quam quae praesentium iste facilis distinctio molestias. Debitis, ex delectus sequi.</text>\n        <text>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Fugit, laudantium nesciunt quo rerum aut voluptatibus aliquam. Quaerat, consequatur iure dicta ut. Esse eius accusamus iure non laboriosam consequuntur reprehenderit maiores.</text>\n        <text>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eum, vitae, voluptatem, sit earum velit suscipit eligendi vel voluptate cupiditate fugiat repellendus animi saepe tempore? Dolorum, corporis officia cum consequatur culpa.</text>\n        <text></text>\n        <text></text>\n    </column>\n  "
    }
  ]
};})();}).call(this);