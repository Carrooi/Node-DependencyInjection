Service = require './Service'
Helpers = require './Helpers'

class DI


	services: null

	reserved: ['di']


	constructor: ->
		di = new Service(@, @)
		di.instantiate = false
		di.injectMethods = false

		@services =
			di: di


	addService: (name, service, args = []) ->
		if name in @reserved
			throw new Error "DI: name '#{name}' is reserved by DI."

		@services[name] = new Service(@, service, args)
		return @services[name]


	autowireArguments: (method, args = []) ->
		return Helpers.autowireArguments(method, args, @)


	createInstance: (service, args = [], instantiate = true, injectMethods = true) ->
		if instantiate == true
			service = Helpers.createInstance(service, args, @)

		if Object.prototype.toString.call(service) == '[object Object]' && injectMethods
			for method of service
				if method.match(/^inject/) != null
					@inject(service[method], service)

		return service


	inject: (fn, scope = {}) ->
		if fn !instanceof Function
			throw new Error 'DI: Inject method can be called only on functions.'

		args = @autowireArguments(fn, [])
		return fn.apply(scope, args)


	hasDefinition: (name) ->
		return typeof @services[name] != 'undefined'


	findDefinitionByName: (name, need = true) ->
		if !@hasDefinition(name)
			if need == true
				throw new Error "DI: Service '#{name}' was not found."
			else
				return null

		return @services[name]


	# deprecated
	getByName: (name) ->
		console.log 'DI: Method getByName is deprecated, use get method.'
		return @get(name)


	get: (name) ->
		return @findDefinitionByName(name).getInstance()


	create: (name) ->
		return @findDefinitionByName(name).create()


	getFactory: (name) ->
		return => return @findDefinitionByName(name).create()


module.exports = DI