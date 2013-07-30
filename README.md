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
	"application": {
		"service": "/path/to/my/application/module",
		"arguments": ["./www", "someOtherVariable"],
		"setup": {
			"setApplicationName": ["nameOfApplication"],
			"setSomethingOther": ["someUselessVariable", "andAnotherOne"]
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

### getByName

Some services may be "singleton" type (not really singleton but with one instance in whole application), which application
service is clearly is.

This method will create one instance of service and store it. Every other time, this instance will be returned.

### create

Method create will just create new instance of service and will not store it.

### getFactory

getFactory is almost the same like create method, but will return annonymous function, so if you then want to use it,
you have to call it.

```
var application = di.getFactory('application');
application = application();		// just call it
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

## Inject methods

If your services using multiple inheritance and you want to inject some other services but it's parent need some different
services, then it is quite uncomfortable to set your services via constructor.

If DI find some methods with "inject" word in the beginning, it will automatically call and autowire these methods.

## Without configuration

Maybe it will be better for someone to use this DI without configuration, so here is example of application and translator
definition.

```
var DI = require('dependency-injection');
var di = new DI;

di.addService('application', '/path/to/my/application/module', ['./www', 'someOtherVariable'])
	.addSetup('setApplicationName', ['nameOfApplication'])
	.addSetup('setSomethingOther', ['someUselessVariable', 'andAnotherOne']);

di.addService('translator', '/path/to/translator')
	.addSetup('setLanguage', ['en']);
```

## Changelog

* 1.0.0
	+ Initial version