(function() { this.design || (this.design = {}); design.livingmaps = (function() { return {"config":{"version":1,"namespace":"livingmaps","groups":{"layout":{"id":"layout","title":"Layout","templates":["column","comparison","mainAndSidebar","multiples3","multiples4"]},"maps":{"id":"maps","title":"maps","templates":["choropleth","map","unemploymentChoropleth"]},"others":{"id":"others","title":"others","templates":["hero","image","info","seperator","subtitle","text","title"]}},"styles":[]},"templates":[{"id":"column","title":"Single Centered Column","html":"<div class=\"row-fluid\"><div class=\"span12\" doc-container=\"\"></div></div>"},{"id":"comparison","title":"Comparison with 2 cols","html":"<div class=\"row-fluid\"><div class=\"span6\" doc-container=\"col-1\"></div><div class=\"span6\" doc-container=\"col-2\"></div></div>"},{"id":"mainAndSidebar","title":"Main and Sidebar Columns","html":"<div class=\"row-fluid\"><div class=\"span8\" doc-container=\"main\"></div><div class=\"span4\" doc-container=\"sidebar\"></div></div>"},{"id":"multiples3","title":"Multiples with 3 cols","html":"<div class=\"row-fluid\"><div class=\"span4\" doc-container=\"col-1\"></div><div class=\"span4\" doc-container=\"col-2\"></div><div class=\"span4\" doc-container=\"col-3\"></div></div>"},{"id":"multiples4","title":"Multiples with 4 cols","html":"<div class=\"row-fluid\"><div class=\"span3\" doc-container=\"col-1\"></div><div class=\"span3\" doc-container=\"col-2\"></div><div class=\"span3\" doc-container=\"col-3\"></div><div class=\"span3\" doc-container=\"col-4\"></div></div>"},{"id":"choropleth","title":"Choropleth","html":"<div data-template=\"\"><div data-is=\"d3-choropleth\" data-dependency=\"d3\" data-dependency-resources=\"http://d3js.org/d3.v3.min.js;https://s3.amazonaws.com/datablog-assets/color_brewer.css;https://s3.amazonaws.com/datablog-assets/d3.geo.projection.min.js\"><p>Couldn't load d3.js dependency. Maybe the service is down?</p></div><p class=\"source\" doc-editable=\"source\" doc-optional=\"\">Description</p></div>"},{"id":"map","title":"Map","html":"<div data-template=\"\"><h3 doc-editable=\"title\" doc-optional=\"\">Title</h3><div data-is=\"leaflet-map\" data-dependency=\"L\" data-dependency-resources=\"http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.js;http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.css;https://s3.amazonaws.com/datablog-assets/leaflet.awesome-markers.js;https://s3.amazonaws.com/datablog-assets/leaflet.awesome-markers.css;https://s3.amazonaws.com/datablog-assets/l.control.geosearch.js;https://s3.amazonaws.com/datablog-assets/l.geosearch.provider.openstreetmap.js;https://s3.amazonaws.com/datablog-assets/l.geosearch.css\"><iframe style=\"width: 100%\" frameborder=\"0\" scrolling=\"no\" marginheight=\"0\" marginwidth=\"0\" src=\"https://maps.google.ch/maps?hl=de&amp;ie=UTF8&amp;ll=46.362093,9.036255&amp;spn=8.279854,10.612793&amp;t=h&amp;z=7&amp;output=embed\"></iframe></div></div>"},{"id":"unemploymentChoropleth","title":"UnemploymentChoropleth","html":"<div data-template=\"\"><h3 doc-editable=\"title\">Title</h3><div data-is=\"d3-choropleth\" data-dependency=\"d3\" data-dependency-resources=\"http://d3js.org/d3.v3.min.js;https://s3.amazonaws.com/datablog-assets/color_brewer.css\"><p>Couldn't load d3.js dependency. Maybe the service is down?</p></div></div>"},{"id":"hero","title":"Hero","html":"<div class=\"hero-unit\"><h1 doc-editable=\"title\">Titel</h1><p doc-editable=\"tagline\">Tagline</p></div>"},{"id":"image","title":"Image","html":"<div class=\"img-polaroid img-full-width\" style=\"margin-bottom: 10px\"><h3 doc-editable=\"title\" doc-optional=\"\">Title</h3><img doc-image=\"image\" src=\"\"><p class=\"source\" doc-editable=\"source\" doc-optional=\"\">Source</p></div>"},{"id":"info","title":"Info","html":"<div class=\"alert alert-info\" doc-editable=\"info\">Lorem Ipsum dolorem</div>"},{"id":"seperator","title":"Seperator","html":"<div><hr></div>"},{"id":"subtitle","title":"Paragraph Title","html":"<h3 doc-editable=\"title\">Lorem ipsum dolorem</h3>"},{"id":"text","title":"Text","html":"<p doc-editable=\"text\">Lorem ipsum dolorem. Lorem ipsum dolorem. Lorem ipsum dolorem</p>"},{"id":"title","title":"Title","html":"<h1 doc-editable=\"title\">Titel</h1>"}],"kickstarters":[{"id":"kickstart","name":"Livingmaps","markup":"<hero><title>Snippet outside container</title><tagline>Yep, it works</tagline></hero><column><main-and-sidebar><main><map is=\"leaflet-map\">An example map</map></main><sidebar><text>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto, a, quam non nobis suscipit nostrum nam modi ducimus voluptate distinctio! Quam, libero, nobis suscipit autem molestias labore officia natus in.</text><text>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Laboriosam, unde, veniam, reprehenderit ipsum blanditiis minima obcaecati modi assumenda eius sapiente nihil cupiditate voluptatum ut ipsa quo harum atque doloribus iste!</text></sidebar></main-and-sidebar><text>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Minima, rerum, maiores nobis vero iure dolorem quisquam excepturi ipsam a quam quae praesentium iste facilis distinctio molestias. Debitis, ex delectus sequi.</text><text>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Fugit, laudantium nesciunt quo rerum aut voluptatibus aliquam. Quaerat, consequatur iure dicta ut. Esse eius accusamus iure non laboriosam consequuntur reprehenderit maiores.</text><text>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eum, vitae, voluptatem, sit earum velit suscipit eligendi vel voluptate cupiditate fugiat repellendus animi saepe tempore? Dolorum, corporis officia cum consequatur culpa.</text><text></text><text></text></column>"}]};})();}).call(this);