(function() {
  module.exports = function(config, http) {
    var mail;
    mail = new (require('./Mail'))(config);
    mail.http = http;
    return mail;
  };

}).call(this);
