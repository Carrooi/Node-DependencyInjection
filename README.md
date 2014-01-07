[![NPM version](https://badge.fury.io/js/dependency-injection.png)](http://badge.fury.io/js/dependency-injection)
[![Dependency Status](https://gemnasium.com/sakren/node-dependency-injection.png)](https://gemnasium.com/sakren/node-dependency-injection)
[![Build Status](https://travis-ci.org/sakren/node-dependency-injection.png?branch=master)](https://travis-ci.org/sakren/node-dependency-injection)

# Dependency injection

Dependency injection with configuration and autowire for node js and browser (for example in combination with [simq](https://npmjs.org/package/simq)).

Imagine, that you have got some classes which are used very often. You have got two options: add instance of these classes
to window object or to any other object, or create new instance every time when you want to use them.

The problem is that first solution add some "mess" to the window object and the other one is even more problematic. What
if you will want to change for example constructor of this class (it's arguments) or call some methods right after class
is instanced? Than you will have to change these setups at every place.

But with this package, you can configure your classes at one place and then let's just "ask" for them. (not service locator).

This package is inspired by dependency injection in [Nette framework](http://doc.nette.org/en/dependency-injection).

## Installation

```
$ npm install dependency-injection
```

## Configuration

You can see full documentation of easy-configuration [here](https://npmjs.org/package/easy-configuration). This package
is used for configuration your services (classes).

```
{
	"services": {
		"application": {
    		"service": "path/to/my/application/module",
    		"arguments": ["./www", "someOtherVariable"],
    		"setup": {
    			"setApplicationName": ["nameOfApplication"],
    			"setSomethingOther": ["someUselessVariable", "andAnotherOne"]
    		}
    	}
	}
}
```

There we set some application service with some arguments which will be given to constructor and some setup. Every time
you will need this service, it will have got these arguments and all setup function will be called.

Section service is path for module require (common js).

DI automatically look into values from setup in your module (service). If it is function, then it will be called, otherwise
argument will be passed into this object property.

## Usage

```
var DIConfigurator = require('dependency-injection/DIConfigurator');
var configurator = new DIConfigurator('./path/to/your/configuration/file.json');

var di = configurator.create();
```

**Relative paths to config files are supported only on node (not in browser)!!!**

This will create new instance of DI class which holding all your services.

You have to also set the basePath property. DI will prepend this basePath to all services' paths from your configuration.
So it should be path to root directory of your application.

In example below, you can see how to get your services.

```
di.get('application');
di.create('application');
di.getFactory('application');
```

## Base path to services

Default base path in node is directory of file from which you are initializing DI. You have to set this manually in browser.

```
di.basePath = __dirname;
```

## Auto exposing into global

DI can be automatically exposed into window object (when on browser) or into global object (in node). Default name for
this object is `di`.

```
{
	"setup": {
		"expose": true
	}
}
```

Custom name:

```
{
	"setup": {
		"expose": "secondDI"
	}
}
```

### get

Some services may be "singleton" type (not really singleton but with one instance in whole application), which application
service is clearly is.

This method will create one instance of service and store it. Every other time, this instance will be returned.

### getByPath

Same as `get` method, but this accepts path to node module (like in your service configuration)

### create

Method create will just create new instance of service and will not store it.

### getFactory

getFactory is almost the same like create method, but will return anonymous function, so if you then want to use it,
you have to call it.

```
var application = di.getFactory('application');
application = application();		// just call it
```

## Not instantiate services

When you want for example use jQuery as service, you will not want to automatically call something like `new jquery`.
So you can tell DI, that this service will not be instantiate.

```
{
	"services": {
		"jquery": {
			"service": "jquery"
			"instantiate": false
		}
	}
}
```

## Auto run services

When you are using configuration with json files, you can set some services to be started automatically after calling
the `create` method.

```
{
	"services": {
		"setup": {
			"service": "./path/to/setup",
			"run": true
		}
	}
}
```

## Autowiring

Accessing some DI object is not so pretty like we want, so there is some nice way how to avoid it. You can let DI to "inject"
all your services to other. For example if your application service needs translator service, just let DI to give it to
application.

All you need to do is add parameter "translator" to constructor of your application service. This name must be same like
name of service in your configuration. DI then automatically give it translator service.

The same thing is also for methods. You don't have to configure them, just set name of needed service in method's arguments
and DI will give you these services.

This is quite similar to dependency injection in [angular](http://angularjs.org/).

Now in most cases you just have to use `get` method just once for create instance of your base application service
and other services will be automatically injected.

Please, try to avoid circular dependencies (service A depends on service B and service B depends on service A).

## Examples

In your configuration, you can use three dots as replacement for services.

Services:
```
var serviceA = function(serviceB, serviceC) { ... };
var serviceB = function(serviceC, namespace, item) { ... };
var serviceC = function(namespace, item, serviceD) { ... };
var serviceD = function() { ... };
```

Configuration:
```
{
	"services": {
		"serviceA": {
			"service": "path/to/service/A",
			"instantiate": false
		},
		"serviceB": {
			"service": "path/to/service/B",
			"arguments": ["...", "some namespace", "some item"],
			"instantiate": false
		},
		"serviceC": {
			"service": "path/to/service/C",
			"arguments": ["some namespace", "some item"],
			"instantiate": false
		},
		"serviceD": {
			"service": "path/to/service/D",
			"instantiate": false
		}
	}
}
```

or more expanded:
```
{
	"services": {
		"serviceA": {
			"service": "path/to/service/A",
			"arguments": ["..."],
			"instantiate": false
		},
		"serviceB": {
			"service": "path/to/service/B",
			"arguments": ["...", "some namespace", "some item"],
			"instantiate": false
		},
		"serviceC": {
			"service": "path/to/service/C",
			"arguments": ["some namespace", "some item", "..."],
			"instantiate": false
		},
		"serviceD": {
			"service": "path/to/service/D",
			"arguments": ["..."],
			"instantiate": false
		}
	}
}
```

Only problem is with minified javascript files which changes variable names. Solution for this is write some kind of hint
for DI container.

```
var someFunction = function(otherNameForApplicationService) {
	{'@di:inject': ['@application']};			// services' names are prepended with '@'

	otherNameForApplicationService.run();		// this will call method run on service application
};
```

or you can also include services by their full paths:
```
var someFunction = function(otherNameForApplicationService) {
	{'@di:inject': ['$path/to/application/service']};		// services' paths are prepended with '$'

	otherNameForApplicationService.run();
};
```

or if you need factory:
```
var someFunction = function(otherNameForApplicationService) {
	{'@di:inject': ['factory:$path/to/application/service']};		// can also be name of service: "factory:@application"

	otherNameForApplicationService.run();
};
```

These hints has got the same syntax as arguments configuration.

### Disable autowiring

If you want to disable autowiring for some service, you can set "autowired" option to false in your config (like instantiate).

When you will try to autowire this service, DI will throw an error.

```
{
	"services": {
		"setup": {
			"someName": "./path/to/this/service",
			"autowired": false
		}
	}
}
```

## Autowire factories

You can also let DI to autowire factories. For example if you want to get factory for translator, you will add "Factory"
to the end of translator.

```
MyClass.prototype.setTranslator = function(translatorFactory) {
	var translator = translatorFactory();			// now do something with translator
};
```

## Links to other services

When you have got for example foreign library registered as service in this DI and want to autowire some other service into
it, you have to use their names of methods arguments.

Another possibility is to set these services in your config.

```
{
	"services": {
		"foreignLibrary": {
			"service": "path/to/service",
			"arguments": [
				"@translator"
			]
		}
	}
}
```

or with full module path:
```
{
	"services": {
		"foreignLibrary": {
			"service": "path/to/service",
			"arguments": [
				"$path/to/translator/module"
			]
		}
	}
}
```

Now this `foreignLibrary` will gets your `translator` service in constructor.

## Autowiring DI

Autowiring DI container is also possible. Only thing you need to do, is set argument with name "di" into your method or
constructor. This also means that you can not register new service with name "di".

```
di.get('di');
```

## Parameters

In documentation of [easy-configuration](https://github.com/sakren/node-easy-configuration) you can see that you can use
also parameters. This is useful for example for setting your services.

```
{
	"parameters": {
		"database": {
			"user": "root",
			"password": "toor"
		}
	},
	"services": {
		"database": {
			"service": "database/connection",
			"arguments": [
				"%database.user%",
				"%database.password%"
			]
		}
	}
}
```

Credentials for database connection will be root and toor.

Or you can access these parameters from di object.

```
console.log(di.parameters);							// whole object of expanded parameters
console.log(di.getParameter('database.user');		// root
```

`getParameter()` method is just shortcut to [getParameter](https://github.com/sakren/node-easy-configuration/blob/master/src/EasyConfiguration.coffee#L173)
method in [easy-configuration](https://github.com/sakren/node-easy-configuration).

## Without configuration

Maybe it will be better for someone to use this DI without configuration, so here is example of application, translator
and jquery definition.

```
var DI = require('dependency-injection');
var di = new DI;

di.addService('application', require('./path/to/my/application/module'), ['./www', 'someOtherVariable'])
	.addSetup('setApplicationName', ['nameOfApplication'])
	.addSetup('setSomethingOther', ['someUselessVariable', 'andAnotherOne']);

di.addService('translator', require('./path/to/translator'))
	.addSetup('setLanguage', ['en']);

di.addService('jquery', 'jquery')
	.setInstantiate(false);

di.addService('private', 'my/private/service')
	.setAutowired(false);
```

Instead of path to service (second parameter in addService method) you can also use string with path, but this path will be
then relative to class of DI!

## Create instance

If you have got some other object which you want to use with other services, but can not use configuration or DI for this,
you can use `createInstance` method and DI will create new instance of your object with dependencies defined in constructor.

```
var SuperClass = require('./mySuperClass');
var super = di.createInstance(SuperClass, ['and some argument']);
```

## Inject method

For simple injecting services into your functions, you can use method `inject`.

```
di.inject(function(application) {
	application.doSomeMagic();
});
```

or with arguments

```
di.inject(function(application, path) {
	application.setPath(path);
}, ['...', '/path/to/some/folder']);		// syntax is same like in configuration
```

you can of course use also autowire hints.

## Tests

```
$ npm test
```

## Changelog

* 2.2.0
	+ Relative paths to config files

* 2.1.1
	+ Hints has exactly the same syntax as arguments configuration
	+ Inject method's second argument is args, not scope (BC break!)

* 2.1.0
	+ Added [config](https://github.com/sakren/node-easy-configuration) object do DIConfigurator
	+ Bug with exposing
	+ Accessing parameters from di instance
	+ Updated dependencies

* 2.0.1
	+ Injecting by arguments and hints was not working

* 2.0.0
	+ Removed autowiring into `inject` methods (BC break!)
	+ Added methods `getByPath` and `getFactoryByPath`
	+ Added basePath option
	+ Better docs
	+ Added hints for autowiring

* 1.8.0
	+ Better tests (mocha does not need to be installed globally)
	+ Updated dependencies
	+ Added badges
	+ Added to travis

* 1.7.3
	+ Bug with no-string arguments

* 1.7.2
	+ Bug with functions as services

* 1.7.1
	+ Potential bug in IE

* 1.7.0
	+ Updated dependencies
	+ Added `injectMethods` to services
	+ Refactored autowiring
	+ Some optimizations
	+ `DI.autowireArguments` moved to `Helpers.autowireArguments`
	+ Throwing an error if circular reference is found

* 1.6.6 - 1.6.7
	+ Bugs in Internet Explorer 8

* 1.6.2 - 1.6.5
	+ Some optimizations
	+ Should assert module replaced with chai
	+ Better error messages

* 1.6.1
	+ Bug with setting other arguments than strings

* 1.6.0
	+ Added `get` method, `getByName` is now deprecated
	+ Added `inject` method
	+ Autowiring with @

* 1.5.2
	+ Add setup into properties

* 1.4.1
	+ Bug

* 1.4.0
	+ Option for exposing di into

* 1.3.2 - 1.3.3
	+ Bug with run option

* 1.3.1
	+ Just some mistake in readme

* 1.3.0
	+ Added auto run option into configuration
	+ Really huge mistake in readme

* 1.2.3
	+ Autowiring parameters even if they are not in function definition

* 1.2.2
	+ Added missing test

* 1.2.1
	+ Added ability to inject DI container itself

* 1.2.0
	+ Added DI.createInstance method
	+ DI.addService accepts also objects
	+ Typos in README
	+ Optimizations
	+ Added mocha tests
	+ Added setInstantiate method
	+ Added autowired option

* 1.1.1
	+ inject methods are called before custom setup

* 1.1.0
	+ Support for not-instantiate services

* 1.0.1
	+ Added information about autowiring factories

* 1.0.0
	+ Initial version