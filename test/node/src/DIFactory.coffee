expect = require('chai').expect
path = require 'path'

DI = require '../../../lib/DI'
DIFactory = require '../../../DIFactory'
Configuration = require 'easy-configuration'

Http = require '../../data/Http'

dir = path.resolve(__dirname + '/../../data')

di = null
factory = null

describe 'DIFactory', ->

	beforeEach( ->
		factory = new DIFactory(dir + '/config.json')
		di = factory.create()
		di.basePath = dir
	)

	describe '#constructor()', ->

		it 'should resolve relative path to absolute path', ->
			factory = new DIFactory('../../data/config.json')
			expect(factory.path).to.be.equal(dir + '/config.json')
			expect(factory.create().parameters.language).to.be.equal('en')

		it 'should create di with custom config object', ->
			config = new Configuration
			config.addConfig('../../data/config.json')
			config.addConfig('../../data/sections.json', 'local')
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