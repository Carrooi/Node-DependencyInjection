class Helpers


	@merge: (left, right) ->
		type = Object.prototype.toString

		if type.call(left) != type.call(right)
			throw new Error 'Can not merge two different objects.'

		switch type.call(left)
			when '[object Array]'
				for value, i in right
					if left.indexOf(value) == -1
						left.push(value)
					else if type.call(value) == '[object Array]' || type.call(value) == '[object Object]'
						left[i] = @merge(left[i], value)
			when '[object Object]'
				for name, value of right
					if typeof left[name] == 'undefined'
						left[name] = value
					else if type.call(value) == '[object Array]' || type.call(value) == '[object Object]'
						left[name] = @merge(left[name], value)

		return left


	@dirName: (path) ->
		num = path.lastIndexOf('/')
		return path.substr(0, num)


	@normalizePath: (path) ->
		parts = path.split('/')

		result = []
		prev = null

		for part in parts
			if part == '.' || part == ''
				continue
			else if part == '..' && prev
				result.pop()
			else
				result.push(part)

			prev = part

		return '/' + result.join('/')


	@stringifyParameters: (parameters, parent = null) ->
		result = {}

		for name, value of parameters
			name = if parent == null then name else parent + '.' + name
			type = Object.prototype.toString.call(value)

			if type == '[object Object]'
				result = @merge(result, @stringifyParameters(value, name))
			else
				result[name] = value

		return result


	@expandParameters: (parameters) ->
		parse = (parameter) ->
			asString = false
			if typeof parameter == 'string'
				asString = true
				parameter = [parameter]

			for param, i in parameter
				parameter[i] = param.replace(/%([a-zA-Z.-_]+)%/g, (match, variable) ->
					if typeof parameters[variable] == 'undefined'
						throw new Error 'Parameter ' + variable + ' was not found'

					return parse(parameters[variable])
				)

			if asString == true
				parameter = parameter[0]

			return parameter

		result = {}
		for name, value of parameters
			result[name] = parse(value)

		return result


	@expandWithParameters: (data, parameters) ->
		replace = (s) ->
			return s.replace(/%([a-zA-Z.-_]+)%/g, (match, variable) ->
				if typeof parameters[variable] == 'undefined'
					throw new Error 'Parameter ' + variable + ' was not found'

				return parameters[variable]
			)

		switch Object.prototype.toString.call(data)
			when '[object String]'
				data = replace(data)
			when '[object Array]'
				for value, i in data
					data[i] = @expandWithParameters(value, parameters)
			when '[object Object]'
				for i, value of data
					data[i] = @expandWithParameters(value, parameters)

		return data


	@objectifyParameters: (parameters) ->
		# todo

		return parameters


module.exports = Helpers