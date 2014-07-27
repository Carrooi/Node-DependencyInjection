(function() {
  var DI, Defaults, Helpers, Service,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Service = require('./Service');

  Helpers = require('./Helpers');

  Defaults = require('./Defaults');

  DI = (function() {
    DI.prototype.services = null;

    DI.prototype.parameters = null;

    DI.prototype.config = null;

    DI.prototype.paths = null;

    DI.prototype.reserved = ['di'];

    DI.prototype.creating = null;

    DI.prototype.basePath = null;

    DI.prototype.instantiate = true;

    function DI() {
      this.services = {};
      this.paths = {};
      this.creating = [];
      new Defaults(this);
    }

    DI.prototype.getParameter = function(parameter) {
      if (this.config === null) {
        throw new Error('DI container was not created with DIFactory.');
      }
      return this.config.getParameter(parameter);
    };

    DI.prototype.getPath = function(name) {
      return (this.basePath === null ? '' : this.basePath + '/') + name;
    };

    DI.prototype.addService = function(name, service, args) {
      var arg, i, originalService, _i, _len;
      if (args == null) {
        args = [];
      }
      if (__indexOf.call(this.reserved, name) >= 0 && typeof this.services[name] !== 'undefined') {
        throw new Error("DI: name '" + name + "' is reserved by DI.");
      }
      originalService = service;
      if (typeof service === 'string') {
        if (service.match(/^(factory\:)?[@$]/)) {
          service = this.tryCallArgument(service);
        } else {
          service = this.resolveModulePath(service);
          if (service === null) {
            throw new Error("Service '" + originalService + "' can not be found.");
          }
          this.paths[service] = name;
        }
      }
      for (i = _i = 0, _len = args.length; _i < _len; i = ++_i) {
        arg = args[i];
        args[i] = this.tryCallArgument(arg);
      }
      this.services[name] = new Service(this, name, service, args);
      this.services[name].setInstantiate(this.instantiate);
      return this.services[name];
    };

    DI.prototype.resolveModulePath = function(_path) {
      var get;
      get = function(p) {
        var err;
        try {
          return require.resolve(p);
        } catch (_error) {
          err = _error;
          return null;
        }
      };
      return get(_path) || get(this.getPath(_path)) || get(Helpers.normalizePath(_path)) || get(Helpers.normalizePath(this.getPath(_path)));
    };

    DI.prototype.tryCallArgument = function(arg) {
      var a, after, args, factory, i, match, original, pos, service, sub, type, _i, _len;
      if (typeof arg !== 'string') {
        return arg;
      }
      if (this.config !== null && (match = arg.match(/^%([a-zA-Z.-_]+)%$/))) {
        return this.getParameter(match[1]);
      }
      if (!arg.match(/^(factory\:)?[@$]/)) {
        return arg;
      }
      factory = false;
      if (arg.match(/^factory\:/)) {
        factory = true;
        arg = arg.substr(8);
      }
      type = arg[0] === '@' ? 'service' : 'path';
      original = arg;
      arg = arg.substr(1);
      service = null;
      after = [];
      if ((pos = arg.indexOf('::')) !== -1) {
        after = arg.substr(pos + 2).split('::');
        arg = arg.substr(0, pos);
      }
      if (type === 'service') {
        service = factory ? this.getFactory(arg) : this.get(arg);
      } else if (type === 'path') {
        service = factory ? this.getFactoryByPath(arg) : this.getByPath(arg);
      }
      if (service === null) {
        throw new Error("Service '" + arg + "' can not be found.");
      }
      if (after.length > 0) {
        args = [];
        while (after.length > 0) {
          sub = after.shift();
          if ((match = sub.match(/^(.+)\((.*)\)$/)) !== null) {
            sub = match[1];
            args = match[2].split(',');
            for (i = _i = 0, _len = args.length; _i < _len; i = ++_i) {
              a = args[i];
              a = a.trim();
              if ((match = a.match(/'(.*)'/)) || (match = a.match(/"(.*)"/))) {
                args[i] = match[1];
              } else if (this.config !== null && (match = a.match(/^%([a-zA-Z.-_]+)%$/))) {
                args[i] = this.getParameter(match[1]);
              } else {
                args[i] = this.tryCallArgument(a);
              }
            }
          }
          if (typeof service[sub] === 'undefined') {
            throw new Error("Can not access '" + sub + "' in '" + original + "'.");
          }
          if (Object.prototype.toString.call(service[sub]) === '[object Function]') {
            service = this.inject(service[sub], args, service);
          } else {
            service = service[sub];
          }
        }
      }
      return service;
    };

    DI.prototype.autowireArguments = function(method, args) {
      if (args == null) {
        args = [];
      }
      Helpers.log('Method autowireArguments is deprecated, use the same method in Helpers class.');
      return Helpers.autowireArguments(method, args, this);
    };

    DI.prototype.createInstance = function(service, args, instantiate) {
      if (args == null) {
        args = [];
      }
      if (instantiate == null) {
        instantiate = true;
      }
      if (instantiate === true) {
        if (Object.prototype.toString.call(service.prototype.constructor) === '[Function]') {
          service = this.inject(service, args, {});
        } else {
          service = Helpers.createInstance(service, args, this);
        }
      }
      return service;
    };

    DI.prototype.inject = function(fn, args, scope) {
      if (args == null) {
        args = [];
      }
      if (scope == null) {
        scope = {};
      }
      if (!(fn instanceof Function)) {
        throw new Error('DI: Inject method can be called only on functions.');
      }
      args = Helpers.autowireArguments(fn, args, this);
      return fn.apply(scope, args);
    };

    DI.prototype.hasDefinition = function(name) {
      return typeof this.services[name] !== 'undefined';
    };

    DI.prototype.findDefinitionByName = function(name, need) {
      if (need == null) {
        need = true;
      }
      if (!this.hasDefinition(name)) {
        if (need === true) {
          throw new Error("DI: Service '" + name + "' was not found.");
        } else {
          return null;
        }
      }
      return this.services[name];
    };

    DI.prototype.getByName = function(name) {
      Helpers.log('DI: Method getByName is deprecated, use get method.');
      return this.get(name);
    };

    DI.prototype.getByPath = function(path) {
      path = this.resolveModulePath(path);
      if (path !== null && typeof this.paths[path] !== 'undefined') {
        return this.get(this.paths[path]);
      }
      return null;
    };

    DI.prototype.getFactoryByPath = function(path) {
      path = this.resolveModulePath(path);
      if (path !== null && typeof this.paths[path] !== 'undefined') {
        return this.getFactory(this.paths[path]);
      }
      return null;
    };

    DI.prototype.get = function(name) {
      return this.findDefinitionByName(name).getInstance();
    };

    DI.prototype.create = function(name) {
      return this.findDefinitionByName(name).create();
    };

    DI.prototype.getFactory = function(name) {
      return (function(_this) {
        return function() {
          return _this.findDefinitionByName(name).create();
        };
      })(this);
    };

    return DI;

  })();

  module.exports = DI;

}).call(this);
