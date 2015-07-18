module.exports = (config, http) ->
	mail = new (require './Mail')(config)
	mail.http = http

	return mail