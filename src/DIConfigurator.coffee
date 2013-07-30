DI = require './DI'
Configuration = require 'easy-configuration'

class DIConfigurator


	path: null

	defaultService:
		service: null
		arguments: []
		instantiate: true
		setup: {}


	constructor: (@path) ->


	create: ->
		config = new Configuration(@path)

		defaults = @defaultService

		services = config.addSection('services')
		services.loadConfiguration = ->
			config = @getConfig()

			for name of config
				config[name] = @configurator.merge(config[name], defaults)

			return config

		data = config.load().services
		di = new DI

		for name, service of data
			s = di.addService(name, service.service, service.arguments)
			s.instantiate = service.instantiate

			for method, arguments of service.setup
				s.addSetup(method, arguments)

		return di


module.exports = DIConfigurator