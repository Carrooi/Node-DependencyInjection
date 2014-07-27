var gulp = require('gulp');
var coffee = require('gulp-coffee');

gulp.task('compile-source', function() {
	gulp.src('./src/**/*.coffee')
		.pipe(coffee())
		.pipe(gulp.dest('./lib'));
});

gulp.task('compile-test-source', function() {
	gulp.src('./test/src/**/*.coffee')
		.pipe(coffee())
		.pipe(gulp.dest('./test/lib'));
});

gulp.task('compile-test-data', function() {
	gulp.src('./test/data/src/**/*.coffee')
		.pipe(coffee())
		.pipe(gulp.dest('./test/data/lib'));
});

gulp.task('compile-test', ['compile-test-source', 'compile-test-data']);
gulp.task('compile', ['compile-source', 'compile-test']);