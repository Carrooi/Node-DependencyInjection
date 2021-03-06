(function() {
  var Http, HttpFactory;

  Http = require('./Http');

  HttpFactory = (function() {
    function HttpFactory() {}

    HttpFactory.prototype.createHttp = function() {
      return new Http;
    };

    return HttpFactory;

  })();

  module.exports = HttpFactory;

}).call(this);
