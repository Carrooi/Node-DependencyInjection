class Helpers


	@clone: (obj) ->
		_type = Object.prototype.toString

		switch _type.call(obj)
			when '[object Array]'
				result = []
				for value, key in obj
					if _type.call(value) in ['[object Array]', '[object Object]']
						result[key] = Helpers.clone(value)
					else
						result[key] = value
			when '[object Object]'
				result = {}
				for key, value of obj
					if _type.call(value) in ['[object Array]', '[object Object]']
						result[key] = Helpers.clone(value)
					else
						result[key] = value
			else
				return obj

		return result


	@dirname: (path) ->



	@log: (message) ->
		if console?.log?
			console.log(message)


	@arrayIndexOf: (array, search) ->
		if typeof Array.prototype.indexOf != 'undefined'
			return array.indexOf(search)

		if array.length == 0
			return -1

		for element, i in array
			if element == search
				return i

		return -1


	@createInstance: (service, args = [], container) ->
		wrapper = (obj, args = []) ->
			f = -> return obj.apply(@, args)
			f.prototype = obj.prototype
			return f

		return new (wrapper(service, Helpers.autowireArguments(service, args, container)))


	@getArguments: (method) ->
		try
			method = method.toString()
		catch e
			throw new Error 'Can not call toString on method'	# todo: try to add name of method

		args = method.slice(method.indexOf('(') + 1, method.indexOf(')')).match(/([^\s,]+)/g)
		args = if args == null then [] else args

		return args


	@getHintArguments: (method) ->
		try
			method = method.toString()
		catch e
			throw new Error 'Can not call toString on method'	# todo: try to add name of method

		body = method.slice(method.indexOf("{") + 1, method.lastIndexOf("}"))
		args = body.match(/{\s*['"]@di:inject['"]\s*:\s*\[(.+)\]\s*}/)

		if args != null
			args = args[1].split(',')
			for arg, i in args
				args[i] = arg.replace(/^\s*['"]/, '').replace(/['"]$/, '')

			return args

		return null


	@autowireArguments: (method, args = [], container) ->
		result = []
		factory = false
		dots = false
		previousDots = false

		hints = Helpers.getHintArguments(method)
		if hints != null
			args = hints

		args = Helpers.clone(args)

		for parameter, i in Helpers.getArguments(method)
			if typeof args[0] != 'undefined' && args[0] == '...'
				dots = true

			# autowire parameter from container by argument name
			if typeof args[0] == 'undefined' || dots || (container.hasDefinition(parameter) && previousDots)
				if parameter.match(/Factory$/) != null
					parameter = parameter.substring(0, parameter.length - 7)
					factory = true

				service = container.findDefinitionByName(parameter)

				if service.autowired == false
					throw new Error "DI: Service '#{parameter}' in not autowired."

				if factory == true
					result.push(container.getFactory(parameter))
				else
					result.push(container.get(parameter))

				if dots
					args.shift()

				previousDots = true

			# custom parameter
			else
				if args[0] != null && typeof args[0] == 'string' && args[0].match(/^factory:/) != null
					args[0] = args[0].substr(8)
					factory = true

				# link to another service
				if args[0] != null && typeof args[0] == 'string' && args[0].match(/^@/) != null
					args[0] = args[0].substr(1)
					if factory
						result.push(container.getFactory(args[0]))
					else
						result.push(container.get(args[0]))

				# link to another services via module path
				else if args[0] != null && typeof args[0] == 'string' && args[0].match(/^\$/) != null
					args[0] = args[0].substr(1)
					if factory
						result.push(container.getFactoryByPath(args[0]))
					else
						result.push(container.getByPath(args[0]))

				# custom parameter
				else
					result.push(args[0])

				previousDots = false
				args.shift()

			factory = false
			dots = false

		return result


module.exports = Helpers