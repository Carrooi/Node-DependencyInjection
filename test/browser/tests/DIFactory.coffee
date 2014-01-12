DI = require 'dependency-injection'
DIFactory = require 'dependency-injection/DIFactory'
Configuration = require 'dependency-injection/Configuration'

dir = '/test/data'

Http = require '/test/data/Http'

di = null
factory = null

describe 'DIFactory', ->

	beforeEach( ->
		factory = new DIFactory(dir + '/config.json')
		di = factory.create()
		di.basePath = dir
	)

	describe '#constructor()', ->

		it 'should throw an error for relative paths', ->
			expect( -> new DIFactory('../data/config.json')).to.throw(Error, 'Relative paths to config files are not supported in browser.')

		it 'should create di with custom config object', ->
			config = new Configuration
			config.addConfig("#{dir}/config.json")
			config.addConfig("#{dir}/sections.json", 'local')
			factory = new DIFactory(config)
			di = factory.create()
			expect(di).to.be.an.instanceof(DI)
			expect(di.parameters.users.david).to.be.equal('divad')

	describe '#parameters', ->

		it 'should contain all parameters', ->
			expect(di.parameters).to.be.eql(
				language: 'en'
				users:
					david: '123456'
					admin: 'nimda'
				database:
					user: 'admin'
					password: 'nimda'
			)

	describe '#getParameter()', ->

		it 'should throw an error if di object was not created from DIFactory', ->
			di = new DI
			expect( -> di.getParameter('buf') ).to.throw(Error, 'DI container was not created with DIFactory.')

		it 'should return expanded parameter', ->
			expect(di.getParameter('database.password')).to.be.equal('nimda')

	describe '#get()', ->

		it 'should load service defined with relative path', ->
			factory = new DIFactory(dir + '/relative.json')
			di = factory.create()
			expect(di.get('http')).to.be.an.instanceof(Http)

		it 'should create services with derived arguments', ->
			factory = new DIFactory(dir + '/derivedArguments.json')
			di = factory.create()
			application = di.get('application')
			expect(application.data).to.be.equal('hello David')
			expect(application.namespace).to.be.false

		it 'should create service derived from other service', ->
			factory = new DIFactory(dir + '/derivedService.json')
			di = factory.create()
			expect(di.get('http')).to.be.an.instanceof(Http)