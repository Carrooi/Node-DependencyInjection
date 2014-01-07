DI = require '/lib/DI'
DIConfigurator = require '/lib/DIConfigurator'
Configuration = require 'easy-configuration'

dir = '/test/data'

di = null
configurator = null

describe 'DIConfiguration', ->

	beforeEach( ->
		configurator = new DIConfigurator(dir + '/config.json')
		di = configurator.create()
		di.basePath = dir
	)

	describe '#constructor()', ->

		it 'should throw an error for relative paths', ->
			expect( -> new DIConfigurator('../data/config.json')).to.throw(Error, 'Relative paths to config files are not supported in browser.')

		it 'should create di with custom configurator object', ->
			config = new Configuration
			config.addConfig("#{dir}/config.json")
			config.addConfig("#{dir}/sections.json", 'local')
			configurator = new DIConfigurator(config)
			di = configurator.create()
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

		it 'should throw an error if di object was not created from DIConfigurator', ->
			di = new DI
			expect( -> di.getParameter('buf') ).to.throw(Error, 'DI container was not created with DIConfigurator.')

		it 'should return expanded parameter', ->
			expect(di.getParameter('database.password')).to.be.equal('nimda')