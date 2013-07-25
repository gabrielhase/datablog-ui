# Generated on 2013-07-01 using generator-angular 0.3.0
LIVERELOAD_PORT = 35729
lrSnippet = require('connect-livereload')(port: LIVERELOAD_PORT)

mountFolder = (connect, dir) ->
  return connect.static(require('path').resolve(dir))

# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'

module.exports = (grunt) ->
  # load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  # configurable paths
  yeomanConfig =
    app: 'app'
    dist: 'dist'


  try
    yeomanConfig.app = require('./bower.json').appPath || yeomanConfig.app
  catch error
    undefined

  grunt.initConfig
    yeoman: yeomanConfig
    watch:
      coffee:
        files: ['<%= yeoman.app %>/scripts/**/*.coffee']
        tasks: ['concurrent:server']
      coffeeTest:
        files: ['test/spec/{,*/}*.coffee']
        tasks: ['coffee:test']
      recess:
        files: ['<%= yeoman.app %>/styles/{,*/}*']
        tasks: ['recess:development']
      livereload:
        options:
          livereload: LIVERELOAD_PORT
        files: [
          '<%= yeoman.app %>/{,*/}*.html'
          '{.tmp,<%= yeoman.app %>}/styles/{,*/}*.css'
          '{.tmp,<%= yeoman.app %>}/scripts/{,*/}*.js'
          '{.tmp,<%= yeoman.app %>}/components/{,*/}*.js'
          '<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
        ]
    connect:
      options:
        port: 9000
        # Change this to '0.0.0.0' to access the server from outside.
        hostname: 'localhost'
      livereload:
        options:
          middleware: (connect) ->
            return [
              lrSnippet
              mountFolder(connect, '.tmp')
              mountFolder(connect, yeomanConfig.app)
            ]
      test:
        options:
          middleware: (connect) ->
            return [
              mountFolder(connect, '.tmp')
              mountFolder(connect, 'test')
            ]
      dist:
        options:
          middleware: (connect) ->
            return [
              mountFolder(connect, yeomanConfig.dist)
            ]
    open:
      server:
        url: 'http://localhost:<%= connect.options.port %>'
    clean:
      dist:
        files: [
          dot: true
          src: [
            '.tmp'
            '<%= yeoman.dist %>/*'
            '!<%= yeoman.dist %>/.git*'
          ]
        ]
      server: '.tmp'
    coffee:
      tmp:
        options:
          join: true
        files: [
          '.tmp/editor.js': [
            'app/scripts/app.coffee'
            'app/scripts/controllers/*.coffee'
            'app/scripts/directives/*.coffee'
            'app/scripts/models/*.coffee'
            'app/scripts/services/*.coffee'
            'app/scripts/templates/*.coffee'
            'app/scripts/components/**/*.coffee'
          ]
        ]
      test:
        options:
          join: true
        files: [
          '.tmp/editor_test.js': [
            'app/scripts/app.coffee'
            'app/scripts/controllers/*.coffee'
            'app/scripts/directives/*.coffee'
            'app/scripts/models/*.coffee'
            'app/scripts/services/*.coffee'
            'app/scripts/templates/*.coffee'
            'app/scripts/components/**/*.coffee'
            'test/spec/**/*.coffee'
          ]
        ]
    recess:
      development:
        options:
          compile: true
        files: [
          # app styles
          expand: true,
          cwd: '<%= yeoman.app %>/styles',
          src: ['*.less'],
          dest: '.tmp/styles',
          ext: '.css'
        ,
          # components styles
          expand: true,
          cwd: '<%= yeoman.app %>/components',
          src: ['**/*.less'],
          dest: '.tmp/styles',
          ext: '.css'
        ]
    rev:
      dist:
        files:
          src: [
            '<%= yeoman.dist %>/scripts/{,*/}*.js'
            '<%= yeoman.dist %>/styles/{,*/}*.css'
            '<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
            '<%= yeoman.dist %>/styles/fonts/*'
          ]
    useminPrepare:
      html: '<%= yeoman.app %>/index.html'
      options:
        dest: '<%= yeoman.dist %>'
    usemin:
      html: ['<%= yeoman.dist %>/{,*/}*.html']
      css: ['<%= yeoman.dist %>/styles/{,*/}*.css']
      options:
        dirs: ['<%= yeoman.dist %>']
    imagemin:
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.app %>/images'
          src: '{,*/}*.{png,jpg,jpeg}'
          dest: '<%= yeoman.dist %>/images'
        ]
    # Put files not handled in other tasks here
    copy:
      dist:
        files: [
          expand: true
          dot: true
          cwd: '<%= yeoman.app %>'
          dest: '<%= yeoman.dist %>'
          src: [
            '*.{ico,png,txt}'
            '.htaccess'
            'images/{,*/}*.{gif,webp,svg,png}'
            'styles/fonts/*'
            'vendor/**/*'
            '*.html'
            'views/*.html'
          ]
        ,
          expand: true
          cwd: '.tmp/images'
          dest: '<%= yeoman.dist %>/images'
          src: [
            'generated/*'
          ]
        ]
    karma:
      unit:
        configFile: 'karma.conf.js'
        browsers: ['PhantomJS']
      once:
        configFile: 'karma.conf.js'
        browsers: ['PhantomJS']
        singleRun: true
      browsers:
        configFile: 'karma.conf.js'
        browsers: ['Chrome', 'Firefox', 'Safari', 'Opera']
      build:
        configFile: 'karma.conf.js'
        browsers: ['Chrome', 'Firefox', 'Safari', 'Opera']
    ngmin:
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.dist %>/scripts'
          src: '*.js'
          dest: '<%= yeoman.dist %>/scripts'
        ]
    uglify:
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.dist %>/scripts'
          src: '*.js'
          dest: '<%= yeoman.dist %>/scripts'
        ]
    concurrent:
      server: [
        'coffee:tmp'
        'coffee:test'
      ]
      test: [
        'coffee'
      ]
      dist: [
        'coffee'
        'imagemin'
        'recess'
      ]

  grunt.registerTask 'server', (target) ->
    if (target == 'dist')
      grunt.task.run(['build', 'open', 'connect:dist:keepalive'])
    else
      grunt.task.run([
        'clean:server'
        'concurrent:server'
        'recess'
        'connect:livereload'
        'open'
        'watch'
      ])

  grunt.registerTask('test', [
    'clean:server'
    'concurrent:test'
    'connect:test'
    'karma'
  ])

  grunt.registerTask('build', [
    'clean:dist'
    'useminPrepare'
    'concurrent:dist'
    'concat'
    'copy'
    'ngmin'
    'rev'
    'usemin'
  ])

  grunt.registerTask('default', [
    'test'
    'build'
  ])
