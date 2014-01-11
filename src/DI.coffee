Service = require './Service'
Helpers = require './Helpers'
Defaults = require './Defaults'

class DI


	services: null

	parameters: null

	config: null

	paths: null

	reserved: ['di']

	creating: null

	basePath: null

	instantiate: true


	constructor: ->
		@services = {}
		@paths = {}
		@creating = []

		new Defaults(@)


	getParameter: (parameter) ->
		if @config == null
			throw new Error 'DI container was not created with DIConfigurator.'

		return @config.getParameter(parameter)


	getPath: (name) ->
		return (if @basePath == null then '' else @basePath + '/') + name


	addService: (name, service, args = []) ->
		if name in @reserved && typeof @services[name] != 'undefined'
			throw new Error "DI: name '#{name}' is reserved by DI."

		originalService = service

		if typeof service == 'string'
			service = @resolveModulePath(service)
			if service == null
				throw new Error "Service '#{originalService}' can not be found."

			@paths[service] = name

		@services[name] = new Service(@, name, service, args)
		return @services[name]


	resolveModulePath: (_path) ->
		get = (p) ->
			try return require.resolve(p)
			catch err then return null

		return get(_path) || get(@getPath(_path))


	# deprecated
	autowireArguments: (method, args = []) ->
		Helpers.log 'Method autowireArguments is deprecated, use the same method in Helpers class.'
		return Helpers.autowireArguments(method, args, @)


	createInstance: (service, args = [], instantiate = true) ->
		if instantiate == true
			if Object.prototype.toString.call(service.prototype.constructor) == '[Function]'
				service = @inject(service, args, {})
			else
				service = Helpers.createInstance(service, args, @)

		return service


	inject: (fn, args = [], scope = {}) ->
		if fn !instanceof Function
			throw new Error 'DI: Inject method can be called only on functions.'

		args = Helpers.autowireArguments(fn, args, @)
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
		Helpers.log 'DI: Method getByName is deprecated, use get method.'
		return @get(name)


	getByPath: (path) ->
		error = false
		try
			path = require.resolve(@getPath(path))
		catch e
			error = true

		if typeof @paths[path] != 'undefined' && !error
			return @get(@paths[path])

		return null


	getFactoryByPath: (path) ->
		error = false
		try
			path = require.resolve(@getPath(path))
		catch e
			error = true

		if typeof @paths[path] != 'undefined' && !error
			return @getFactory(@paths[path])

		return null


	get: (name) ->
		return @findDefinitionByName(name).getInstance()


	create: (name) ->
		return @findDefinitionByName(name).create()


	getFactory: (name) ->
		return => return @findDefinitionByName(name).create()


module.exports = DI