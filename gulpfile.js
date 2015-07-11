// npm install --save-dev gulp gulp-coffeelint gulp-uglify browserify browserify-shim coffeeify del vinyl-buffer vinyl-source-stream gulp-concat gulp-connect

var gulp       = require('gulp');
var coffeelint = require('gulp-coffeelint');
var uglify     = require('gulp-uglify');

var browserify = require('browserify');
var coffeeify  = require('coffeeify');
var del        = require('del');
var buffer     = require('vinyl-buffer');
var vinyl      = require('vinyl-source-stream');

var concat = require('gulp-concat');
var connect = require('gulp-connect');

//var deploy = require('gulp-gh-pages');

var paths = {
  assets: [
    './app/assets/**/*.*',
    './app/index.html'
  ],
  app: './app',
  dist: './dist',
  js: './app/js/app.coffee',
  lint: './app/js/*.coffee',
  watch: './app/js/*.coffee',
  vendor: ['./vendor/js/phaser.min.js'],
  css: './app/css/main.css',
  deploy: './dist/**/*'
};

gulp.task('connect', function() {
  connect.server({
    root: paths.dist,
    livereload: false
  });
});

// не используется
gulp.task('connect-reload', function(){
  connect.reload()
});

gulp.task('lint', function() {
  return gulp.src(paths.lint)
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())
    .pipe(coffeelint.reporter('failOnWarning'));
});

gulp.task('clean', function(cb) {
  del(paths.dist, cb);
});

gulp.task('copy-assets', function() {
  return gulp.src(paths.assets, {base: paths.app})
    .pipe(gulp.dest(paths.dist));
});

gulp.task('copy-css', function(){
   return gulp.src(paths.css, {base: paths.app})
    .pipe(gulp.dest(paths.dist));
});

gulp.task('compile-coffee', function() {
  return browserify(paths.js)
    .transform(coffeeify)
    .bundle()
    .pipe(vinyl('main.js'))
    .pipe(buffer())
    //.pipe(uglify())
    .pipe(gulp.dest(paths.dist));
});

gulp.task('compile-js', ['compile-coffee'], function() {
  return gulp.src(paths.vendor.concat([paths.dist + "/main.js"]))
    .pipe(concat('main.js'))
    .pipe(gulp.dest(paths.dist));
});

// не используется
gulp.task('watch', function() {
  gulp.watch(paths.watch, ['compile-js']);
});


gulp.task('default', ['clean'], function() {
  gulp.start('copy-assets', 'copy-css','compile-js');
});

gulp.task('generate_level', function(){
  result = []

  x = 2300

  while(x > 100){
    result.push([x, Math.round(Math.random() * (24 - 1) + 1)]);

    x -= 300
  }

  console.log(result);
});

// gulp.task('deploy', function() {
//     return gulp.src(paths.deploy)
//         .pipe(deploy());
// });
