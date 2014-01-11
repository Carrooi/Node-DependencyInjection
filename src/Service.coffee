Helpers = require './Helpers'

class Service


	di: null

	name: null

	service: null

	arguments: null

	instantiate: true

	autowired: true

	setup: null

	instance: null


	constructor: (@di, @name, @service, @arguments = []) ->
		@setup = {}
		@instantiate = @di.instantiate


	getInstance: ->
		if @instance == null
			@instance = @create()

		return @instance


	create: ->
		if Helpers.arrayIndexOf(@di.creating, @name) != -1
			s = if @di.creating.length == 1 then '' else 's'
			names = @di.creating.join(', ')
			throw new Error "Circular reference detected for service#{s}: #{names}."

		@di.creating.push(@name)

		service = @service
		if Object.prototype.toString.call(service) == '[object String]'
			service = require(service)

		try
			service = @di.createInstance(service, @arguments, @instantiate)

			for method, args of @setup
				if @setup.hasOwnProperty(method)
					if typeof service[method] == 'function'
						service[method].apply(service, Helpers.autowireArguments(service[method], args, @di))
					else
						service[method] = args
		catch e
			@di.creating.splice(Helpers.arrayIndexOf(@di.creating, @name), 1)
			throw e

		@di.creating.splice(Helpers.arrayIndexOf(@di.creating, @name), 1)

		return service


	addSetup: (method, args = []) ->
		@setup[method] = args
		return @


	setInstantiate: (@instantiate) ->
		return @


	setAutowired: (@autowired) ->
		return @


module.exports = Service