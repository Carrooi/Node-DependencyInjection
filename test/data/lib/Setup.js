(function() {
  var Setup;

  Setup = (function() {
    Setup.prototype.callsite = null;

    function Setup(callsite) {
      this.callsite = callsite;
    }

    return Setup;

  })();

  module.exports = Setup;

}).call(this);
