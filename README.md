# watson-ui

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
