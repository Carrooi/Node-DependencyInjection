expect = require('chai').expect
path = require 'path'

DI = require '../../lib/DI'
Service = require '../../lib/Service'
Helpers = require '../../lib/Helpers'

Application = require '../data/Application'
Http = require '../data/Http'

di = null
dir = '/test/data'

describe 'Helpers', ->

	beforeEach( ->
		di = new DI
	)

	describe '#createInstance()', ->

		it 'should create new instance of object with given arguments', ->
			app = Helpers.createInstance(Application, ['test'], di)
			expect(app).to.be.an.instanceof(Application)
			expect(app.array).to.be.equal('test')

	describe '#getArguments()', ->

		it 'should return an empty array', ->
			expect(Helpers.getArguments( -> )).to.be.eql([])

		it 'should return an array with arguments', ->
			expect(Helpers.getArguments( (first, second, third) -> )).to.be.eql(['first', 'second', 'third'])

	describe '#autowireArguments()', ->

		it 'should return array with services for Application', ->
			di.addService('array', Array)
			expect(Helpers.autowireArguments(Application, [], di)).to.be.eql([[]])

		it 'should return array with services for inject method', ->
			di.addService('http', Http)
			args = Helpers.autowireArguments((new Application([])).injectHttp, [], di)
			expect(args).to.have.length(1)
			expect(args[0]).to.be.an.instanceof(Http)

		it 'should return array with services for Application with custom ones', ->
			di.addService('info', ['hello']).setInstantiate(false)
			app = new Application([])
			expect(Helpers.autowireArguments(app.prepare, ['simq'], di)).to.be.eql(['simq', ['hello']])

		it 'should throw an error if service to autowire does not exists', ->
			expect( -> Helpers.autowireArguments(Application, [], di) ).to.throw(Error, "DI: Service 'array' was not found.")

		it 'should return array with services from params if they are not in definition', ->
			app = new Application([])
			expect(Helpers.autowireArguments(app.withoutDefinition, ['hello'], di)).to.be.eql(['hello'])

		it 'should inject another service by at char', ->
			fn = (variable) -> return variable
			di.addService('array', Array)
			expect(Helpers.autowireArguments(fn, ['@array'], di)).to.be.eql([[]])

		it 'should inject services replaced with dots in the end', ->
			fn = (first, second, third) -> return arguments
			di.addService('second', ['second item']).instantiate = false
			di.addService('third', ['third item']).instantiate = false
			expect(Helpers.autowireArguments(fn, ['test', '...'], di)).to.be.eql(['test', ['second item'], ['third item']])

		it 'should inject services replaced with dots in the beginning', ->
			fn = (first, second, third) -> return arguments
			di.addService('first', ['first item']).instantiate = false
			di.addService('second', ['second item']).instantiate = false
			expect(Helpers.autowireArguments(fn, ['...', 'test'], di)).to.be.eql([['first item'], ['second item'], 'test'])