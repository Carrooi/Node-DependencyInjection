Http = require './Http'

class HttpFactory


	createHttp: ->
		return new Http


module.exports = HttpFactory