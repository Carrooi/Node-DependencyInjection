class Application


	array: null

	http: null

	namespace: null

	info: null

	data: null

	di: null

	diFactory: null

	other: null


	constructor: (@array) ->


	setHttp: (@http) ->


	prepare: (@namespace, @info) ->
		return @namespace


	setData: (noArray = null) ->
		@data = noArray


	setDi: (@di) ->


	setDiFactory: (@diFactory) ->


	withoutDefinition: (param) ->
		@other = arguments


module.exports = Application