DI = require './DI'
Configuration = require 'easy-configuration'

class DIConfigurator


	@EXPOSE_NAME = 'di'


	path: null

	defaultSetup:
		windowExpose: false

	defaultService:
		service: null
		arguments: []
		instantiate: true
		autowired: true
		run: false
		setup: {}


	constructor: (@path) ->


	create: ->
		config = new Configuration(@path)

		defaultService = @defaultService
		config.addSection('services').loadConfiguration = ->
			config = @getConfig()

			for name of config
				if config.hasOwnProperty(name) && name not in ['__proto__']
					config[name] = @configurator.merge(config[name], defaultService)

			return config

		defaultSetup = @defaultSetup
		config.addSection('setup').loadConfiguration = ->
			return @getConfig(defaultSetup)

		configuration = config.load()
		di = new DI

		expose = configuration.setup.windowExpose
		if expose != false && typeof window != 'undefined'
			name = if typeof expose == 'string' then expose else DIConfigurator.EXPOSE_NAME
			window[name] = di

		run = []

		for name, service of configuration.services
			if configuration.services.hasOwnProperty(name) && name not in ['__proto__']
				s = di.addService(name, service.service, service.arguments)
				s.setInstantiate(service.instantiate)
				s.setAutowired(service.autowired)

				for method, arguments of service.setup
					if service.setup.hasOwnProperty(method)
						s.addSetup(method, arguments)

				if service.run == true
					run.push(name)

		for name in run
			di.get(name)

		return di


module.exports = DIConfigurator