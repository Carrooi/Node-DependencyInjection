(function() {
  module.exports = function() {
    return new (require('./Mail'))('test mail');
  };

}).call(this);
