(function() {
  var MySql;

  MySql = (function() {
    MySql.prototype.parameters = null;

    function MySql(parameters) {
      this.parameters = parameters;
    }

    MySql.create = function(parameters) {
      return new MySql(parameters);
    };

    return MySql;

  })();

  module.exports = MySql;

}).call(this);
