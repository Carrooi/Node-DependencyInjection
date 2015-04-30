(function() {
  var Application, AutowirePath, DI, Helpers, Http, Service, di, dir, expect, path;

  expect = require('chai').expect;

  path = require('path');

  DI = require('../../lib/DI');

  Service = require('../../lib/Service');

  Helpers = require('../../lib/Helpers');

  Application = require('../data/lib/Application');

  Http = require('../data/lib/Http');

  AutowirePath = require('../data/lib/AutowirePath');

  di = null;

  dir = path.resolve(__dirname + '/../data/lib');

  describe('Helpers', function() {
    beforeEach(function() {
      di = new DI;
      return di.basePath = path.resolve(__dirname + '/..');
    });
    describe('#createInstance()', function() {
      return it('should create new instance of object with given arguments', function() {
        var app;
        app = Helpers.createInstance(Application, ['test'], di);
        expect(app).to.be.an["instanceof"](Application);
        return expect(app.array).to.be.equal('test');
      });
    });
    describe('#getArguments()', function() {
      it('should return an empty array', function() {
        return expect(Helpers.getArguments(function() {})).to.be.eql([]);
      });
      return it('should return an array with arguments', function() {
        return expect(Helpers.getArguments(function(first, second, third) {})).to.be.eql(['first', 'second', 'third']);
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
        args = Helpers.autowireArguments((new Application([])).setHttp, [], di);
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
      it('should inject service by full path', function() {
        var fn;
        fn = function(something) {
          return {
            '@di:inject': ['$data/lib/AutowirePath']
          };
        };
        di.addService('someRandomName', "" + dir + "/AutowirePath");
        return expect(Helpers.autowireArguments(fn, null, di)[0]).to.be.an["instanceof"](AutowirePath);
      });
      it('should inject factory to service with hint and full path', function() {
        var args, fn;
        fn = function(arg) {
          return {
            '@di:inject': ["factory:$data/lib/AutowirePath"]
          };
        };
        di.addService('greatService', "" + dir + "/AutowirePath");
        args = Helpers.autowireArguments(fn, null, di);
        expect(args[0]).to.be.a('function');
        return expect(args[0]()).to.be.an["instanceof"](AutowirePath);
      });
      it('should inject factory to service with hint and just name', function() {
        var args, fn;
        fn = function(arg) {
          return {
            '@di:inject': ['factory:@greatService']
          };
        };
        di.addService('greatService', "" + dir + "/AutowirePath");
        args = Helpers.autowireArguments(fn, null, di);
        expect(args[0]).to.be.a('function');
        return expect(args[0]()).to.be.an["instanceof"](AutowirePath);
      });
      it('should inject services replaced with dots in the end of hints', function() {
        var fn;
        fn = function(first, second, third) {
          ({
            '@di:inject': ['test', '...']
          });
          return arguments;
        };
        di.addService('second', ['second item']).instantiate = false;
        di.addService('third', ['third item']).instantiate = false;
        return expect(Helpers.autowireArguments(fn, [], di)).to.be.eql(['test', ['second item'], ['third item']]);
      });
      it('should inject services replaced with dots in the beginning of hints', function() {
        var fn;
        fn = function(first, second, third) {
          ({
            '@di:inject': ['...', 'test']
          });
          return arguments;
        };
        di.addService('first', ['first item']).instantiate = false;
        di.addService('second', ['second item']).instantiate = false;
        return expect(Helpers.autowireArguments(fn, [], di)).to.be.eql([['first item'], ['second item'], 'test']);
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