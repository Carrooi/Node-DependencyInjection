class Application


	array: null

	http: null

	namespace: null

	info: null

	data: null

	di: null

	diFactory: null


	constructor: (@array) ->


	injectHttp: (@http) ->


	prepare: (@namespace, @info) ->
		return @namespace


	setData: (noArray = null) ->
		@data = noArray


	setDi: (@di) ->


	setDiFactory: (@diFactory) ->


module.exports = Application