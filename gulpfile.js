var gulp = require('gulp');
var coffee = require('gulp-coffee');
var browserify = require('gulp-browserify');
var rename = require('gulp-rename');

gulp.task('compile-source', function() {
	gulp.src('./src/**/*.coffee')
		.pipe(coffee())
		.pipe(gulp.dest('./lib'));
});

gulp.task('compile-test-node', function() {
	gulp.src('./test/node/src/**/*.coffee')
		.pipe(coffee())
		.pipe(gulp.dest('./test/node/lib'));
});

gulp.task('compile-test-browser', function() {
	gulp.src('./test/browser/index.coffee', {'read': false})
		.pipe(browserify({
			transform: ['coffeeify'],
			extensions: ['.coffee']
		}))
		.pipe(rename('application.js'))
		.pipe(gulp.dest('./test/browser/'));
});

gulp.task('compile-test-data', function() {
	gulp.src('./test/data/**/*.coffee')
		.pipe(coffee())
		.pipe(gulp.dest('./test/data'));
});

gulp.task('compile-test', ['compile-test-node', 'compile-test-browser', 'compile-test-data']);
gulp.task('compile', ['compile-source', 'compile-test-node', 'compile-test-browser', 'compile-test-data']);