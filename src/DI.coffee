Service = require './Service'

class DI


	services: {}


	addService: (name, service, args = []) ->
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
				if arg.match(/Factory$/) == null
					result.push(@getByName(arg))
				else
					arg = arg.substring(0, arg.length - 7)
					result.push(@getFactory(arg))
			else
				result.push(args[i])

		return result


	findDefinitionByName: (name, need = true) ->
		if typeof @services[name] == 'undefined'
			if need == true
				throw new Error 'DI: Service with name ' + name + ' was not found'
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