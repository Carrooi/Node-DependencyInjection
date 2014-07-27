(function() {
  var Mail;

  Mail = (function() {
    Mail.prototype.setup = null;

    Mail.prototype.http = null;

    function Mail(setup) {
      this.setup = setup;
    }

    return Mail;

  })();

  module.exports = Mail;

}).call(this);
