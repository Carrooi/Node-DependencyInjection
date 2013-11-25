// Generated by CoffeeScript 1.6.3
(function() {
  var Application, DI, Helpers, Http, Service, di, dir, expect, path;

  expect = require('chai').expect;

  path = require('path');

  DI = require('../../lib/DI');

  Service = require('../../lib/Service');

  Helpers = require('../../lib/Helpers');

  Application = require('../data/Application');

  Http = require('../data/Http');

  di = null;

  dir = '/test/data';

  describe('Helpers', function() {
    beforeEach(function() {
      return di = new DI;
    });
    describe('#createInstance()', function() {
      return it('should create new instance of object with given arguments', function() {
        var app;
        app = Helpers.createInstance(Application, ['test'], di);
        expect(app).to.be.an["instanceof"](Application);
        return expect(app.array).to.be.equal('test');
      });
    });
    return describe('#autowireArguments()', function() {
      it('should return array with services for Application', function() {
        di.addService('array', Array);
        return expect(Helpers.autowireArguments(Application, [], di)).to.be.eql([[]]);
      });
      it('should return array with services for inject method', function() {
        var args;
        di.addService('http', Http);
        args = Helpers.autowireArguments((new Application([])).injectHttp, [], di);
        expect(args).to.have.length(1);
        return expect(args[0]).to.be.an["instanceof"](Http);
      });
      it('should return array with services for Application with custom ones', function() {
        var app;
        di.addService('info', ['hello']).setInstantiate(false);
        app = new Application([]);
        return expect(Helpers.autowireArguments(app.prepare, ['simq'], di)).to.be.eql(['simq', ['hello']]);
      });
      it('should throw an error if service to autowire does not exists', function() {
        return expect(function() {
          return Helpers.autowireArguments(Application, [], di);
        }).to["throw"](Error, "DI: Service 'array' was not found.");
      });
      it('should return array with services from params if they are not in definition', function() {
        var app;
        app = new Application([]);
        return expect(Helpers.autowireArguments(app.withoutDefinition, ['hello'], di)).to.be.eql(['hello']);
      });
      it('should inject another service by at char', function() {
        var fn;
        fn = function(variable) {
          return variable;
        };
        di.addService('array', Array);
        return expect(Helpers.autowireArguments(fn, ['@array'], di)).to.be.eql([[]]);
      });
      it('should inject services replaced with dots in the end', function() {
        var fn;
        fn = function(first, second, third) {
          return arguments;
        };
        di.addService('second', ['second item']).instantiate = false;
        di.addService('third', ['third item']).instantiate = false;
        return expect(Helpers.autowireArguments(fn, ['test', '...'], di)).to.be.eql(['test', ['second item'], ['third item']]);
      });
      return it('should inject services replaced with dots in the beginning', function() {
        var fn;
        fn = function(first, second, third) {
          return arguments;
        };
        di.addService('first', ['first item']).instantiate = false;
        di.addService('second', ['second item']).instantiate = false;
        return expect(Helpers.autowireArguments(fn, ['...', 'test'], di)).to.be.eql([['first item'], ['second item'], 'test']);
      });
    });
  });

}).call(this);
