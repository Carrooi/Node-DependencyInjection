var gulp = require('gulp');
var coffee = require('gulp-coffee');

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

gulp.task('compile-test-data', function() {
	gulp.src('./test/data/**/*.coffee')
		.pipe(coffee())
		.pipe(gulp.dest('./test/data'));
});

gulp.task('compile-test', ['compile-test-node', 'compile-test-browser', 'compile-test-data']);
gulp.task('compile', ['compile-source', 'compile-test-node', 'compile-test-data']);