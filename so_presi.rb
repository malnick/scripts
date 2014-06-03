/* Render Showoff presentation to png or pdf.
   For PNG output:
   * Install
       - phantomjs
   * Run
       $> showoff serve &
       $> phantomjs ./path/to/showoff2png.js
   This will create one png image file per slide.
 
 * For PDF output:
   * Install
     - phantomjs
     - ImageMagick
     - pdftk
   * Run
     $> showoff serve &
     $> phantomjs ./path/to/showoff2png.js
     $> convert *.png +adjoin slide-%04d.pdf
     $> pdftk slide*.pdf cat output preso.pdf
     $> rm slide*.pdf
   This will firstly create one pdf file per png image,
   secondly merge all pdfs into one. The last command
   deletes all temporary pdf files.
*/
 
String.prototype.repeat = function( num ) {
	for( var i = 0, buf = ""; i < num; i++ ) buf += this;
	return buf;
}
 
String.prototype.rjust = function( width, padding ) {
  padding = padding || " ";
  padding = padding.substr( 0, 1 );
  if( this.length < width ){
    return padding.repeat( width - this.length ) + this;
  } else {
    return this;
  }
}
 
function render_showoff_preso(t, max){
  var url = 'http://localhost:9090/#'+t;
  var page = require('webpage').create();
  page.viewportSize = {width: 1024, height: 768};
  page.clipRect = { top: 0, left: 0, width: 1024, height: 778}
  page.open(url, function (status) {
    window.setTimeout(function () {
      page.evaluate(function () {
        $('.incremental > ul > li').attr('style', '');
      });
      console.log('SAVE slide ' + t + ' of ' + max);
      page.render('showoff_preso_' + (t).toString().rjust(4,'0') + '.png');
    }, 5000);
  });
  window.setTimeout(function () {
    if(t < max){
      render_showoff_preso(t+1, max);
    } else {
      window.setTimeout(function () {
        phantom.exit(0);
      }, 6000);
    }
  }, 500);
}
 
 
var url = 'http://localhost:9090/';
var page = require('webpage').create();
var slide_count = 1;
page.open(url, function (status) {
  slide_count = page.evaluate(function () {
  return slides.length;
  });
  render_showoff_preso(1, parseInt(slide_count));
});