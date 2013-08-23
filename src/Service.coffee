class Service


	di: null

	service: null

	arguments: null

	instantiate: true

	autowired: true

	setup: null

	instance: null


	constructor: (@di, @service, @arguments = []) ->
		@setup = {}


	getInstance: ->
		if @instance == null
			@instance = @create()

		return @instance


	create: ->
		service = @service
		if Object.prototype.toString.call(service) == '[object String]'
			service = require(service)

		service = @di.createInstance(service, @arguments, @instantiate)

		for method, args of @setup
			if typeof service[method] == 'function'
				service[method].apply(service, @di.autowireArguments(service[method], args))
			else
				service[method] = args

		return service


	addSetup: (method, args = []) ->
		@setup[method] = args
		return @


	setInstantiate: (@instantiate) ->
		return @


	setAutowired: (@autowired) ->
		return @


module.exports = Service