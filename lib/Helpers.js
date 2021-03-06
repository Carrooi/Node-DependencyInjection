(function() {
  var Helpers;

  Helpers = (function() {
    function Helpers() {}

    Helpers.clone = function(obj) {
      var key, result, value, _i, _len, _ref, _ref1, _type;
      _type = Object.prototype.toString;
      switch (_type.call(obj)) {
        case '[object Array]':
          result = [];
          for (key = _i = 0, _len = obj.length; _i < _len; key = ++_i) {
            value = obj[key];
            if ((_ref = _type.call(value)) === '[object Array]' || _ref === '[object Object]') {
              result[key] = Helpers.clone(value);
            } else {
              result[key] = value;
            }
          }
          break;
        case '[object Object]':
          result = {};
          for (key in obj) {
            value = obj[key];
            if ((_ref1 = _type.call(value)) === '[object Array]' || _ref1 === '[object Object]') {
              result[key] = Helpers.clone(value);
            } else {
              result[key] = value;
            }
          }
          break;
        default:
          return obj;
      }
      return result;
    };

    Helpers.dirName = function(path) {
      var num;
      num = path.lastIndexOf('/');
      return path.substr(0, num);
    };

    Helpers.normalizePath = function(path) {
      var part, parts, prev, result, _i, _len;
      parts = path.split('/');
      result = [];
      prev = null;
      for (_i = 0, _len = parts.length; _i < _len; _i++) {
        part = parts[_i];
        if (part === '.' || part === '') {
          continue;
        } else if (part === '..' && prev) {
          result.pop();
        } else {
          result.push(part);
        }
        prev = part;
      }
      return '/' + result.join('/');
    };

    Helpers.log = function(message) {
      if ((typeof console !== "undefined" && console !== null ? console.log : void 0) != null) {
        return console.log(message);
      }
    };

    Helpers.arrayIndexOf = function(array, search) {
      var element, i, _i, _len;
      if (typeof Array.prototype.indexOf !== 'undefined') {
        return array.indexOf(search);
      }
      if (array.length === 0) {
        return -1;
      }
      for (i = _i = 0, _len = array.length; _i < _len; i = ++_i) {
        element = array[i];
        if (element === search) {
          return i;
        }
      }
      return -1;
    };

    Helpers.createInstance = function(service, args, container) {
      var wrapper;
      if (args == null) {
        args = [];
      }
      wrapper = function(obj, args) {
        var f;
        if (args == null) {
          args = [];
        }
        f = function() {
          return obj.apply(this, args);
        };
        f.prototype = obj.prototype;
        return f;
      };
      return new (wrapper(service, Helpers.autowireArguments(service, args, container)));
    };

    Helpers.getArguments = function(method) {
      var args, e;
      try {
        method = method.toString();
      } catch (_error) {
        e = _error;
        throw new Error('Can not call toString on method');
      }
      args = method.slice(method.indexOf('(') + 1, method.indexOf(')')).match(/([^\s,]+)/g);
      args = args === null ? [] : args;
      return args;
    };

    Helpers.getHintArguments = function(method) {
      var arg, args, body, e, i, _i, _len;
      try {
        method = method.toString();
      } catch (_error) {
        e = _error;
        throw new Error('Can not call toString on method');
      }
      body = method.slice(method.indexOf("{") + 1, method.lastIndexOf("}"));
      args = body.match(/{\s*['"]@di:inject['"]\s*:\s*\[(.+)\]\s*}/);
      if (args !== null) {
        args = args[1].split(',');
        for (i = _i = 0, _len = args.length; _i < _len; i = ++_i) {
          arg = args[i];
          args[i] = arg.replace(/^\s*['"]/, '').replace(/['"]$/, '');
        }
        return args;
      }
      return null;
    };

    Helpers.autowireArguments = function(method, args, container) {
      var dots, factory, hints, i, parameter, previousDots, result, service, _i, _len, _ref;
      if (args == null) {
        args = [];
      }
      result = [];
      factory = false;
      dots = false;
      previousDots = false;
      hints = Helpers.getHintArguments(method);
      if (hints !== null) {
        args = hints;
      }
      args = Helpers.clone(args);
      _ref = Helpers.getArguments(method);
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        parameter = _ref[i];
        if (typeof args[0] !== 'undefined' && args[0] === '...') {
          dots = true;
        }
        if (typeof args[0] === 'undefined' || dots || (container.hasDefinition(parameter) && previousDots)) {
          if (parameter.match(/Factory$/) !== null) {
            parameter = parameter.substring(0, parameter.length - 7);
            factory = true;
          }
          service = container.findDefinitionByName(parameter);
          if (service.autowired === false) {
            throw new Error("DI: Service '" + parameter + "' in not autowired.");
          }
          if (factory === true) {
            result.push(container.getFactory(parameter));
          } else {
            result.push(container.get(parameter));
          }
          if (dots) {
            args.shift();
          }
          previousDots = true;
        } else {
          result.push(container.tryCallArgument(args[0]));
          previousDots = false;
          args.shift();
        }
        factory = false;
        dots = false;
      }
      return result;
    };

    return Helpers;

  })();

  module.exports = Helpers;

}).call(this);
