# datablog-ui

## What is this?

This repository was initially created as a clone of an existing UI project from livingdocs. It will be changed and adpated to hold interactive map snippets developed for my master thesis in the ALM in IT.
Once the strategy and structure of the map snippets is sufficiently clear they will probably be factored out in their own (open) repositories.

If necessary, changes can be taken back and forth from the livingdocs UI project with git patches.

## Requirements and Setup

**node and npm**
  
  1. Install node.js and npm (http://nodejs.org/)
  2. Install grunt using `npm install -g grunt-cli`
  3. From the root of the project run `npm install`

### Export

To export all necessary scripts, styles and assets, run:
```bash
grunt build
```
This will create a `dist` folder with everything you need.


### Development Server

During development run  
```bash
grunt server
```
This will watch and build css as well as coffeescript and start a livereloading server at localhost:9000


### Folder structure

Code is supposed to be developed within the scripts folder by a layer-model. As soon as a module is clear enough to be a self-sufficient part it should be factored out and put into the components folder which is structured by function, i.e. module.

## Licence

<a rel="license" href="http://creativecommons.org/licenses/by-nc/3.0/deed.en_US"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc/3.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">datablog</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="http://datablog.io" property="cc:attributionName" rel="cc:attributionURL">livingdocs.io</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc/3.0/deed.en_US">Creative Commons Attribution-NonCommercial 3.0 Unported License</a>.<br />Based on a work at <a xmlns:dct="http://purl.org/dc/terms/" href="https://github.com/gabrielhase/datablog-ui" rel="dct:source">https://github.com/gabrielhase/datablog-ui</a>.
