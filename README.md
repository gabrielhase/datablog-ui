## What is this

The datablog-ui implementation allows editing text, images, and two kinds of map elements directly in the browser. It is the accompanying code repository for the livingmap, a Harvard University Extension School master thesis. A public demo page of this project can be found at [datablog.io](http://www.datablog.io/).

If you care about the map elements, i.e. choropleths and web maps, you will likely need to dive into the code and integrate them with your code respectively. Web maps are created with the [angular-leaflet-directive](http://tombatossals.github.io/angular-leaflet-directive), which is an awesome open source stand-alone directive for interactive maps. You probably want to start there and see how the datablog-ui integrates the directive into an editing environment with forms and modals. The choropleth maps are supported with a custom directive that can be found in the code's `directives` folder.

If you care about the text editing and drag&drop capabilities, you need the software library livingdocs, which is not open source, but was provided as is for the livingmap master thesis project. Get in touch with the guys at [livingdocs.io](http://www.livingdocs.io), chances are high they let you use their software.

## How to set it up

### requirements (for all other points)

1. Install node and npm, [node.js](http://nodejs.org/)
2. From the top directory, run `npm install`

### server

You can run the server in both local and api mode. Out of the box, only the local mode is supported, which is also the default. If you want to save your documents to a server, you will need to implement the API layer found in `components/api`.
So to run the server in local mode use either:
```
grunt server
```
or 
```
grunt server --api=local
```

If you want to run it with your own API (requires that you implement the api layer) then run:
```
grunt server --api=<name of your api>
```

### specs

The specs are pretty slow. I am sorry... To run them, type:
```
grunt test
```

### build

The build task creates the `dist` folder for you. You can then take this folder and deploy it anywhere you like (the datablog.io demo page uses github pages).
To build the project, run:
```
grunt build
```

NOTE: The build task will by default use the API layer. If you want to build a local version, e.g. to have a demo page that stores to the browsers local storage, run:
```
grunt build --api=local
```

## Credits

No code is an island! The datablog-ui project builds upon a lot of really awesome tools and libraries. Below is a list of all of them (please tell me, if I forgot something):

### Code libraries

name | webpage | licence
----|------|----
JQuery | http://www.jquery.com  | MIT
Angular.JS | http://www.angularjs.org  | MIT
d3.js | http://www.d3js.org  | [custom](https://github.com/mbostock/d3/blob/master/LICENSE)
d3-geo-projection | https://github.com/d3/d3-geo-projection/ | [custom](https://github.com/d3/d3-geo-projection/blob/master/LICENSE)
leaflet.js | http://leafletjs.com/ | [custom](https://github.com/Leaflet/Leaflet/blob/master/LICENSE)
livingdocs | http://www.livingdocs.io | closed source (copyright)
moment.js | http://momentjs.com/ | [custom](https://github.com/moment/moment/blob/develop/LICENSE)
underscore.js | http://underscorejs.org/ | [custom](https://github.com/jashkenas/underscore/blob/master/LICENSE)
ng-grid | http://angular-ui.github.io/ng-grid/ | MIT
ng-progress | http://victorbjelkholm.github.io/ngProgress/ | MIT
UI Bootstrap | http://angular-ui.github.io/bootstrap/ | MIT
angular-truncate | https://github.com/sparkalow/angular-truncate | MIT

### Design resources

name | webpage | licence
----|------|----
colorbrewer | https://github.com/mbostock/d3/tree/master/lib/colorbrewer | Apache
GADM maps | http://www.gadm.org/ | non-commercial use only
bootstrap | http://getbootstrap.com/ | MIT


## Licence

Copyright 2014 Gabriel Hase, gabriel(dot)hase(at)gmail(dot)com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public 
License along with this program.  If not, see 
<http://www.gnu.org/licenses/>.

NOTE: This licence does not include third-party libraries. Please check
the Credits section of the README.md file for details.
