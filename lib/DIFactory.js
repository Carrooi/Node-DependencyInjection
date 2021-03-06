(function() {
  var Configuration, DI, DIFactory, Helpers, callsite, isWindow, path;

  DI = require('./DI');

  Helpers = require('./Helpers');

  Configuration = require('easy-configuration');

  isWindow = typeof window !== 'undefined';

  if (!isWindow) {
    callsite = require('callsite');
    path = require('path');
  }

  DIFactory = (function() {
    DIFactory.EXPOSE_NAME = 'di';

    DIFactory.prototype.config = null;

    DIFactory.prototype.path = null;

    DIFactory.prototype.basePath = null;

    DIFactory.prototype.defaultDefaults = {
      instantiate: true
    };

    DIFactory.prototype.defaultSetup = {
      windowExpose: null,
      expose: false
    };

    DIFactory.prototype.defaultService = {
      service: null,
      factory: null,
      "arguments": [],
      instantiate: null,
      autowired: true,
      run: false,
      setup: {}
    };

    function DIFactory(pathOrConfig) {
      var section, stack, _path, _ref;
      if (typeof pathOrConfig === 'string') {
        if (pathOrConfig[0] === '.' && isWindow) {
          throw new Error('Relative paths to config files are not supported in browser.');
        }
        if (pathOrConfig[0] === '.') {
          stack = callsite();
          this.basePath = path.dirname(stack[1].getFileName());
          pathOrConfig = path.join(this.basePath, pathOrConfig);
        }
        this.path = pathOrConfig;
        this.config = new Configuration(this.path);
      } else if (pathOrConfig instanceof Configuration) {
        this.config = pathOrConfig;
      } else {
        throw new Error('Bad argument');
      }
      if (this.basePath === null) {
        _ref = this.config.files;
        for (_path in _ref) {
          section = _ref[_path];
          break;
        }
        this.basePath = Helpers.dirName(_path);
      }
    }

    DIFactory.prototype.create = function() {
      var configuration, defaultDefaults, defaultService, defaultSetup, di, expose, method, name, run, s, service, serviceName, _i, _len, _ref, _ref1;
      defaultService = this.defaultService;
      this.config.addSection('services').loadConfiguration = function() {
        var config, name;
        config = this.getConfig();
        for (name in config) {
          if (config.hasOwnProperty(name) && (name !== '__proto__')) {
            config[name] = this.configurator.merge(config[name], defaultService);
          }
        }
        return config;
      };
      defaultSetup = this.defaultSetup;
      this.config.addSection('setup').loadConfiguration = function() {
        return this.getConfig(defaultSetup);
      };
      defaultDefaults = this.defaultDefaults;
      this.config.addSection('defaults').loadConfiguration = function() {
        return this.getConfig(defaultDefaults);
      };
      configuration = this.config.load();
      di = new DI;
      if (this.basePath !== null) {
        di.basePath = this.basePath;
      }
      di.config = this.config;
      di.parameters = this.config.parameters;
      di.instantiate = configuration.defaults.instantiate;
      if (configuration.setup.windowExpose !== null) {
        console.log('Option windowExpose is deprecated. Please use expose.');
        configuration.setup.expose = configuration.setup.windowExpose;
      }
      expose = configuration.setup.expose;
      if (expose !== false) {
        name = typeof expose === 'string' ? expose : DIFactory.EXPOSE_NAME;
        if (typeof window !== 'undefined') {
          window[name] = di;
        } else if (typeof global !== 'undefined') {
          global[name] = di;
        }
      }
      run = [];
      _ref = configuration.services;
      for (name in _ref) {
        service = _ref[name];
        if (configuration.services.hasOwnProperty(name) && (name !== '__proto__')) {
          serviceName = service.service || service.factory;
          if (service.instantiate === null) {
            if (serviceName.match(/^(factory\:)?[@$]/) || service.factory !== null) {
              service.instantiate = false;
            } else {
              service.instantiate = true;
            }
          }
          s = di.addService(name, serviceName, service["arguments"], service.factory !== null).setAutowired(service.autowired).setInstantiate(service.instantiate);
          _ref1 = service.setup;
          for (method in _ref1) {
            arguments = _ref1[method];
            if (service.setup.hasOwnProperty(method)) {
              s.addSetup(method, arguments);
            }
          }
          if (service.run === true) {
            run.push(name);
          }
        }
      }
      for (_i = 0, _len = run.length; _i < _len; _i++) {
        name = run[_i];
        di.get(name);
      }
      return di;
    };

    return DIFactory;

  })();

  module.exports = DIFactory;

}).call(this);
