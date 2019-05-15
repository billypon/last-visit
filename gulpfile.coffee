gulp = require 'gulp'

pump = (fn) ->
	(cb) ->
		streams = fn()
		callback = streams.pop() unless streams[streams.length - 1].pipe
		require('pump') streams, unless callback then cb else ->
			callback()
			cb.apply this, arguments
		return

clean = (src) ->
	src = [ src ] unless src.map
	src = src.map (x) ->
		if x[0] != '!' then 'dist/' + x else '!dist/' + x.substr 1
	pump ->
		[
			gulp.src src
			(require 'gulp-clean')()
		]

gulp.task 'html', pump ->
	pug = require 'gulp-pug'
	[
		gulp.src 'src/*.pug'
		pug
			pretty: true
		gulp.dest 'dist'
	]

gulp.task 'css', pump ->
	stylus = require 'gulp-stylus'
	[
		gulp.src 'src/css/*.styl'
		stylus
			'include css': true
		gulp.dest 'dist/css'
	]

gulp.task 'js', pump ->
	[
		gulp.src 'src/js/*.coffee'
		(require 'gulp-coffee')
			bare: true
		gulp.dest 'dist/js'
	]

gulp.task 'copy', [ 'copy:manifest', 'copy:locales' ], pump ->
	[
		gulp.src 'src/icon/*'
		gulp.dest 'dist/icon'
	]

gulp.task 'copy:manifest', pump ->
	[
		gulp.src 'src/manifest.json'
		gulp.dest 'dist'
	]

gulp.task 'copy:locales', pump ->
	[
		gulp.src 'src/_locales/**/*', base: 'src'
		gulp.dest 'dist'
	]

gulp.task 'version', [ 'copy:manifest' ], pump ->
	{version} = require './package.json'
	replace = require 'gulp-replace'
	[
		gulp.src 'dist/manifest.json'
		replace 'VERSION', version
		gulp.dest 'dist'
	]

gulp.task 'watch', [ 'html', 'css', 'js', 'copy', 'version' ], ->
	gulp.watch 'src/*.pug', [ 'html' ]
	gulp.watch 'src/css/*.styl', [ 'css' ]
	gulp.watch 'src/js/*.coffee', [ 'js' ]
	gulp.watch 'src/manifest.json', [ 'copy:manifest', 'version' ]
	gulp.watch 'src/_locales/**/*', [ 'copy:locales' ]

gulp.task 'build', [ 'html', 'css', 'js', 'copy', 'version' ]

gulp.task 'clean', clean '*'
