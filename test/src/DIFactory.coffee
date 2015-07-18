expect = require('chai').expect
path = require 'path'
callsite = require 'callsite'

DI = require '../../lib/DI'
DIFactory = require '../../DIFactory'
Configuration = require '../../Configuration'

Http = require '../data/lib/Http'
Database = require '../data/lib/MySql'
Mail = require '../data/lib/Mail'

dir = path.resolve(__dirname + '/../data')

di = null
factory = null

describe 'DIFactory', ->

	beforeEach( ->
		factory = new DIFactory(dir + '/config/config.json')
		di = factory.create()
		di.basePath = dir
	)

	describe '#constructor()', ->

		it 'should resolve relative path to absolute path', ->
			factory = new DIFactory('../data/config/config.json')
			expect(factory.path).to.be.equal(dir + '/config/config.json')
			expect(factory.create().parameters.language).to.be.equal('en')

		it 'should create di with custom config object', ->
			config = new Configuration
			config.addConfig('../data/config/config.json')
			config.addConfig('../data/config/sections.json', 'local')
			factory = new DIFactory(config)
			di = factory.create()
			expect(di).to.be.an.instanceof(DI)
			expect(di.parameters.users.david).to.be.equal('divad')

		it 'should create database service from factory with list of parameters', ->
			factory = new DIFactory(dir + '/config/database.json')
			di = factory.create()
			db = di.get('database')
			expect(db).to.be.an.instanceof(Database)
			expect(db.parameters).to.be.eql(
				host: 'localhost'
				user: 'root'
				password: 'toor'
				database: 'application'
			)

		it 'should create service with list of parameters', ->
			factory = new DIFactory(dir + '/config/mail.json')
			di = factory.create()
			mail = di.get('mail')
			expect(mail).to.be.an.instanceof(Mail)
			expect(mail.setup).to.be.eql(
				type: 'SMTP'
				auth:
					user: 'root'
					pass: 'toor'
			)

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
			factory = new DIFactory(dir + '/config/relative.json')
			di = factory.create()
			expect(di.get('http')).to.be.an.instanceof(Http)

		it 'should create services with derived arguments', ->
			factory = new DIFactory(dir + '/config/derivedArguments.json')
			di = factory.create()
			application = di.get('application')
			expect(application.data).to.be.equal('hello David')
			expect(application.namespace).to.be.false

		it 'should create service derived from other service', ->
			factory = new DIFactory(dir + '/config/derivedService.json')
			di = factory.create()
			expect(di.get('http')).to.be.an.instanceof(Http)

		it 'should create service from exported factory function', ->
			factory = new DIFactory(dir + '/config/factory.json')
			di = factory.create()
			mail = di.get('mail')
			expect(mail).to.be.an.instanceof(Mail)
			expect(mail.setup).to.be.eql(
				type: 'SMTP'
				auth:
					user: 'root'
					pass: 'toor'
			)
			expect(mail.http).to.be.an.instanceof(Http)

		it 'should create npm service', ->
			factory = new DIFactory(dir + '/config/nodeModules.json')
			di = factory.create()
			expect(di.get('callsite')).to.be.equal(callsite)
			expect(di.get('setup').callsite).to.be.equal(callsite)

		it 'should create npm service from function factory', ->
			factory = new DIFactory(dir + '/config/nodeModules.json')
			di = factory.create()
			expect(di.get('callsiteFactory')).to.be.equal(callsite)