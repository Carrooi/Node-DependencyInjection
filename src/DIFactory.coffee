DI = require './DI'
Helpers = require './Helpers'
Configuration = require 'easy-configuration'

isWindow = typeof window != 'undefined'

if !isWindow
	callsite = require 'callsite'
	path = require 'path'

class DIFactory


	@EXPOSE_NAME = 'di'


	config: null

	path: null

	basePath: null

	defaultDefaults:
		instantiate: true

	defaultSetup:
		windowExpose: null		# deprecated
		expose: false

	defaultService:
		service: null
		arguments: []
		instantiate: null
		autowired: true
		run: false
		setup: {}


	constructor: (pathOrConfig) ->
		if typeof pathOrConfig == 'string'
			if pathOrConfig[0] == '.' && isWindow
				throw new Error 'Relative paths to config files are not supported in browser.'

			if pathOrConfig[0] == '.'
				stack = callsite()
				@basePath = path.dirname(stack[1].getFileName())
				pathOrConfig = path.join(@basePath, pathOrConfig)

			@path = pathOrConfig
			@config = new Configuration(@path)

		else if pathOrConfig instanceof Configuration
			@config = pathOrConfig

		else
			throw new Error 'Bad argument'

		if @basePath == null
			break for _path, section of @config.files
			@basePath = Helpers.dirName(_path)


	create: ->
		defaultService = @defaultService
		@config.addSection('services').loadConfiguration = ->
			config = @getConfig()

			for name of config
				if config.hasOwnProperty(name) && name not in ['__proto__']
					config[name] = @configurator.merge(config[name], defaultService)

			return config

		defaultSetup = @defaultSetup
		@config.addSection('setup').loadConfiguration = ->
			return @getConfig(defaultSetup)

		defaultDefaults = @defaultDefaults
		@config.addSection('defaults').loadConfiguration = ->
			return @getConfig(defaultDefaults)

		configuration = @config.load()
		di = new DI

		if @basePath != null
			di.basePath = @basePath

		di.config = @config
		di.parameters = @config.parameters
		di.instantiate = configuration.defaults.instantiate

		if configuration.setup.windowExpose != null
			console.log 'Option windowExpose is deprecated. Please use expose.'
			configuration.setup.expose = configuration.setup.windowExpose

		expose = configuration.setup.expose
		if expose != false
			name = if typeof expose == 'string' then expose else DIFactory.EXPOSE_NAME
			if typeof window != 'undefined'
				window[name] = di
			else if typeof global != 'undefined'
				global[name] = di

		run = []

		for name, service of configuration.services
			if configuration.services.hasOwnProperty(name) && name not in ['__proto__']
				if service.instantiate == null
					if service.service.match(/^(factory\:)?[@$]/)
						service.instantiate = false
					else
						service.instantiate = true

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


module.exports = DIFactory