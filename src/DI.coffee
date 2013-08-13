Service = require './Service'

class DI


	services: null

	reserved: ['di']


	constructor: ->
		@services = {}


	addService: (name, service, args = []) ->
		if name in @reserved
			throw new Error "DI: name '#{name}' is reserved by DI"

		@services[name] = new Service(@, service, args)
		return @services[name]


	autowireArguments: (method, args = []) ->
		method = method.toString()
		method = method.replace(/((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg, '')		# comments
		methodArgs = method.slice(method.indexOf('(') + 1, method.indexOf(')')).match(/([^\s,]+)/g)
		methodArgs = if methodArgs == null then [] else methodArgs

		result = []
		for arg, i in methodArgs
			if typeof args[i] == 'undefined' || args[i] == '...'
				factory = false
				if arg.match(/Factory$/) != null
					arg = arg.substring(0, arg.length - 7)
					factory = true

				if arg == 'di'
					self = if factory == true then => return @ else @
					result.push(self)
				else if @findDefinitionByName(arg).autowired == false
					throw new Error "DI: service #{arg} can not be autowired"
				else if factory == true
					result.push(@getFactory(arg))
				else
					result.push(@getByName(arg))

			else
				result.push(args[i])

		return result


	@_newInstanceWrapper = (obj, args = []) ->
		f = -> return obj.apply(@, args)
		f.prototype = obj.prototype
		return f


	createInstance: (service, args = [], instantiate = true) ->
		if instantiate == true
			service = new (DI._newInstanceWrapper(service, @autowireArguments(service, args)))

		for method of service
			if method.match(/^inject/) != null
				service[method].apply(service, @autowireArguments(service[method], []))

		return service


	findDefinitionByName: (name, need = true) ->
		if typeof @services[name] == 'undefined'
			if need == true
				throw new Error "DI: Service '#{name}' was not found"
			else
				return null

		return @services[name]


	getByName: (name) ->
		return @findDefinitionByName(name).getInstance()


	create: (name) ->
		return @findDefinitionByName(name).create()


	getFactory: (name) ->
		return => return @findDefinitionByName(name).create()


module.exports = DI