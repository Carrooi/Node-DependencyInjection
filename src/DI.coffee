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
			throw new Error 'DI container was not created with DIFactory.'

		return @config.getParameter(parameter)


	getPath: (name) ->
		return (if @basePath == null then '' else @basePath + '/') + name


	addService: (name, service, args = []) ->
		if name in @reserved && typeof @services[name] != 'undefined'
			throw new Error "DI: name '#{name}' is reserved by DI."

		originalService = service
		instantiate = @instantiate
		factory = false

		if typeof service == 'string'
			if service.match(/^(factory\:)?[@$]/)
				service = @tryCallArgument(service)
			else
				if match = service.match(/^(.+)\(.*\)$/)
					service = match[1]
					instantiate = false
					factory = true

				service = @resolveModulePath(service)
				if service == null
					throw new Error "Service '#{originalService}' can not be found."

				@paths[service] = name

		for arg, i in args
			args[i] = @tryCallArgument(arg)

		@services[name] = (new Service(@, name, service, args))
			.setInstantiate(instantiate)
			.setFactory(factory)

		return @services[name]


	resolveModulePath: (_path) ->
		get = (p) ->
			try return require.resolve(p)
			catch err then return null

		return get(_path) || get(@getPath(_path)) || get(Helpers.normalizePath(_path)) || get(Helpers.normalizePath(@getPath(_path)))


	tryCallArgument: (arg) ->
		if typeof arg != 'string'
			return arg

		if (@config != null && (match = arg.match(/^%([a-zA-Z.-_]+)%$/)))
			return @getParameter(match[1])

		if !arg.match(/^(factory\:)?[@$]/)
			return arg

		factory = false
		if arg.match(/^factory\:/)
			factory = true
			arg = arg.substr(8)

		type = if arg[0] == '@' then 'service' else 'path'
		original = arg
		arg = arg.substr(1)
		service = null
		after = []

		if (pos = arg.indexOf('::')) != -1
			after = arg.substr(pos + 2).split('::')
			arg = arg.substr(0, pos)

		if type == 'service'
			service = if factory then @getFactory(arg) else @get(arg)
		else if type == 'path'
			service = if factory then @getFactoryByPath(arg) else @getByPath(arg)

		if service == null
			throw new Error "Service '#{arg}' can not be found."

		if after.length > 0
			args = []
			while after.length > 0
				sub = after.shift()
				if (match = sub.match(/^(.+)\((.*)\)$/)) != null
					sub = match[1]
					args = match[2].split(',')
					for a, i in args
						a = a.trim()
						if (match = a.match(/'(.*)'/)) || (match = a.match(/"(.*)"/))
							args[i] = match[1]
						else if (@config != null && (match = a.match(/^%([a-zA-Z.-_]+)%$/)))
							args[i] = @getParameter(match[1])
						else
							args[i] = @tryCallArgument(a)

				if typeof service[sub] == 'undefined'
					throw new Error "Can not access '#{sub}' in '#{original}'."

				if Object.prototype.toString.call(service[sub]) == '[object Function]'
					service = @inject(service[sub], args, service)
				else
					service = service[sub]

		return service


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
		path = @resolveModulePath(path)
		if path != null && typeof @paths[path] != 'undefined'
			return @get(@paths[path])

		return null


	getFactoryByPath: (path) ->
		path = @resolveModulePath(path)
		if path != null && typeof @paths[path] != 'undefined'
			return @getFactory(@paths[path])

		return null


	get: (name) ->
		return @findDefinitionByName(name).getInstance()


	create: (name) ->
		return @findDefinitionByName(name).create()


	getFactory: (name) ->
		return => return @findDefinitionByName(name).create()


module.exports = DI