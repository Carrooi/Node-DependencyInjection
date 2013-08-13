class Application


	array: null

	http: null

	namespace: null

	info: null

	data: null


	constructor: (@array) ->


	injectHttp: (@http) ->


	prepare: (@namespace, @info) ->
		return @namespace


	setData: (noArray = null) ->
		@data = noArray


module.exports = Application