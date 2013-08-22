# Dependency injection

Dependency injection with configuration and autowire for node js and browser (for example in combination with [simq](https://npmjs.org/package/simq)).

Imagine, that you have got some classes which are used very often. You have got two options: add instance of these classes
to window object or to any other object, or create new instance every time when you want to use them.

The problem is that first solution add some "mess" to the window object and the other one is even more problematic. What
if you will want to change for example constructor of this class (it's arguments) or call some methods right after class
is instanced? Than you will have to change these setups at every place.

But with this package, you can configure your classes at one place and then let's just "ask" for them. (not service locator).

This package is inspired by dependency injection in [Nette framework](http://doc.nette.org/en/dependency-injection).

## Changelog

Changelog is at the end of this readme.

## Configuration

You can see full documentation of easy-configuration [here](https://npmjs.org/package/easy-configuration). This package
is used for configuration your services (classes).

```
{
	"services": {
		"application": {
    		"service": "/path/to/my/application/module",
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

## Usage

```
var DIConfigurator = require('dependency-injection/DIConfigurator');
var configurator = new DIConfigurator('/path/to/your/configuration/file.json');

var di = configurator.create();
```

This will create new instance of DI class which holding all your services.

In example below, you can see how to get your services.

```
di.getByName('application');
di.create('application');
di.getFactory('application');
```

## Auto exposing into window

DI can be automatically exposed into window object (when on browser). Default name for this object is `di`.

```
{
	"setup": {
		"windowExpose": true
	}
}
```

Custom name:

```
{
	"setup": {
		"windowExpose": "configurator"
	}
}
```

### getByName

Some services may be "singleton" type (not really singleton but with one instance in whole application), which application
service is clearly is.

This method will create one instance of service and store it. Every other time, this instance will be returned.

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

Now in most cases you just have to use getByName method just once for create instance of your base application service
and other services will be automatically injected.

Please, try to avoid circular dependencies (service A depends on service B and service B depends on service A).

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

## Autowiring DI

Autowiring DI container is also possible. Only thing you need to do, is set argument with name "di" into your method or
constructor. This also means that you can not register new service with name "di".

## Inject methods

If your services using multiple inheritance and you want to inject some other services but it's parent need some different
services, then it is quite uncomfortable to set your services via constructor.

If DI find some methods with "inject" word in the beginning, it will automatically call and autowire these methods.

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

di.addService('private', '/my/private/service')
	.setAutowired(false);
```

Instead of path to service (second parameter in addService method) you can also use string with path, but this path will be
then relative to class of DI!

## Create instance

If you have got some other object which you want to use with other services, but can not use configuration or DI for this,
you can use `createInstance` method and DI will create new instance of your object with dependencies defined in constructor
or with inject methods.

```
var SuperClass = require('./mySuperClass');
var super = di.createInstance(SuperClass, ['and some argument']);
```

## Changelog

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