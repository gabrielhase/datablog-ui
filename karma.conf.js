// Karma configuration

module.exports = function(config) {
  config.set({
    // base path, that will be used to resolve files and exclude
    basePath: '',


    // frameworks to use
    frameworks: ['mocha', 'sinon-chai'],


    // list of files / patterns to load in the browser
    files: [
      'test/runner.html',

      // the big guns
      'app/vendor/jquery-1.9.1.js',
      'app/vendor/angular/angular.js',
      "https://ajax.googleapis.com/ajax/libs/angularjs/1.2.0-rc.2/angular.min.js",
      'app/vendor/angular/angular-mocks.js',
      'app/vendor/angular-ui-bootstrap/*.js',

      // livingdocs designs
      'app/vendor/livingmaps-design/design.js',

      // livingdocs-engine
      'app/vendor/livingdocs-engine/vendor/yepnope/yepnope.1.5.3-min.js',

      // Maps
      'app/vendor/leaflet/angular_leaflet_directive.js',

      // D3
      'http://d3js.org/d3.v3.js',

      // API
      'app/scripts/components/environment/constants.js',

      // APP
      'app/scripts/utils/*.coffee',
      'app/scripts/app.coffee',
      'app/scripts/controllers/*.coffee',
      'app/scripts/directives/*.coffee',
      'app/scripts/models/*.coffee',
      'app/scripts/services/*.coffee',
      'app/scripts/templates/*.coffee',
      'app/scripts/components/**/component.coffee',
      'app/scripts/components/**/*.coffee',
      'test/spec/**/*.coffee'
    ],

    // NOTE: The first preprocessor should also include 'coverage'
    // At the moment coffeescript code coverage is broken, but this pull-request
    // should fix it. Staying tuned...
    // https://github.com/karma-runner/karma-coverage/pull/19
    preprocessors: {
      'app/scripts/**/*.coffee': ['coffee'],
      'test/**/*.coffee': ['coffee'],
      "test/*.html": "html2js"
    },

    // list of files to exclude
    exclude: [],

    // test results reporter to use
    // possible values: dots || progress || growl
    reporters: ['dots', 'coverage'],

    // web server port
    port: 8090,

    // cli runner port
    runnerPort: 9100,

    // enable / disable colors in the output (reporters and logs)
    colors: true,

    // level of logging
    // possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
    logLevel: config.LOG_INFO,

    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,

    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: ['PhantomJS'],

    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 15000,

    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false,

    coverageReporter: {
      type: 'html',
      dir: 'coverage/'
    }

  });
};
