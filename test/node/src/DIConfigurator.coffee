expect = require('chai').expect
path = require 'path'

DI = require '../../../lib/DI'
DIConfigurator = require '../../../lib/DIConfigurator'
Configuration = require 'easy-configuration'

dir = path.resolve(__dirname + '/../../data')

di = null
configurator = null

describe 'DIConfiguration', ->

	beforeEach( ->
		configurator = new DIConfigurator(dir + '/config.json')
		di = configurator.create()
		di.basePath = dir
	)

	describe '#constructor()', ->

		it 'should resolve relative path to absolute path', ->
			configurator = new DIConfigurator('../../data/config.json')
			expect(configurator.path).to.be.equal(dir + '/config.json')
			expect(configurator.create().parameters.language).to.be.equal('en')

		it 'should create di with custom configurator object', ->
			config = new Configuration
			config.addConfig('../../data/config.json')
			config.addConfig('../../data/sections.json', 'local')
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