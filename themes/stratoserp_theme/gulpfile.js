const gulp = require('gulp');
const postcss = require('gulp-postcss');
const autoprefixer = require('autoprefixer');
const cssnano = require('cssnano');
const sourcemaps = require('gulp-sourcemaps');
const sass = require('gulp-sass')(require('sass'));
const rsync = require('gulp-rsync');

const paths = {
  styles: {
    src: "scss/**/*.scss",
    dest: "css"
  }
};

function style() {
  return gulp
    .src(paths.styles.src)
    .pipe(sourcemaps.init())
    .pipe(sass())
    .on('error', sass.logError)
    .pipe(postcss([autoprefixer(), cssnano()]))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(paths.styles.dest))
    .pipe(rsync({destination: '../../../profiles/contrib/stratoserp_base/themes/stratoserp_theme/'}))
}

function watch() {
  style();

  gulp.watch(paths.styles.src, style)
}

exports.watch = watch;
exports.style = style;
