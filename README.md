# watson-ui

## Requirements

- npm

## Development

Setup the development environment by running:

    $ npm install

### Development Server

    $ grunt server

### Development API

By default the watson-ui uses the staging server API at api.thelivingdoc.com. This is set in app.coffee. For local development you can easily point the API to your local machines livingdocs server, just be sure to start the livingdocs server.

### Folder structure

Code is supposed to be developed within the scripts folder by a layer-model. As soon as a module is clear enough to be a self-sufficient part it should be factored out and put into the components folder which is structured by function, i.e. module.
