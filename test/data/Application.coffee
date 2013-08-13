class Application


	array: null

	http: null

	namespace: null

	info: null

	data: null

	di: null


	constructor: (@array) ->


	injectHttp: (@http) ->


	prepare: (@namespace, @info) ->
		return @namespace


	setData: (noArray = null) ->
		@data = noArray


	setDi: (@di) ->


module.exports = Application