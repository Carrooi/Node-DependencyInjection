(function() {
  var Http;

  Http = (function() {
    function Http() {}

    Http.prototype.async = false;

    Http.prototype.greetings = function(name) {
      return 'hello ' + name;
    };

    return Http;

  })();

  module.exports = Http;

}).call(this);
