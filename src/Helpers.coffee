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



	@getArguments: (method) ->
		method = method.toString()
		method = method.replace(/((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg, '')		# remove comments

		args = method.slice(method.indexOf('(') + 1, method.indexOf(')')).match(/([^\s,]+)/g)
		args = if args == null then [] else args

		return args


	@autowireArguments: (method, args = [], container) ->
		result = []
		factory = false
		dots = false
		previousDots = false

		args = Helpers.clone(args)

		for parameter in Helpers.getArguments(method)
			if typeof args[0] != 'undefined' && args[0] == '...'
				dots = true

			if parameter.match(/Factory$/) != null
				parameter = parameter.substring(0, parameter.length - 7)
				factory = true

			# autowire parameter from container
			if typeof args[0] == 'undefined' || dots || (container.hasDefinition(parameter) && previousDots)

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

				# link to another service
				if args[0] != null && args[0].match(/^@/) != null
					args[0] = args[0].substr(1)
					result.push(container.get(args[0]))

				# custom parameter
				else
					result.push(args[0])

				previousDots = false
				args.shift()

			factory = false
			dots = false

		return result


module.exports = Helpers