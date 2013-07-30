class Service


	di: null

	service: null

	arguments: null

	instantiate: true

	setup: null

	instance: null


	constructor: (@di, @service, @arguments = []) ->
		@setup = {}


	getInstance: ->
		if @instance == null
			@instance = @create()

		return @instance


	create: ->
		wrapper = (service, args = []) ->
			f = -> return service.apply(@, args)
			f.prototype = service.prototype
			return f

		service = require(@service)

		if @instantiate == true
			service = new (wrapper(service, @di.autowireArguments(service, @arguments)))

		called = []
		for method, args of @setup
			service[method].apply(service, @di.autowireArguments(service[method], args))
			called.push(method)

		for method of service
			if called.indexOf(method) == -1 && method.match(/^inject/) != null
				service[method].apply(service, @di.autowireArguments(service[method], []))

		return service


	addSetup: (method, args = []) ->
		@setup[method] = args
		return @


module.exports = Service