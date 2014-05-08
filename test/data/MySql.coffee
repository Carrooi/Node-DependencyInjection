class MySql


	parameters: null


	constructor: (@parameters) ->


	@create: (parameters) ->
		new MySql(parameters)



module.exports = MySql