expect = require('chai').expect
path = require 'path'

DI = require '../../lib/DI'
Service = require '../../lib/Service'

Application = require '../data/Application'
Http = require '../data/Http'

di = null
dir = path.resolve(__dirname + '/../data')

describe 'DI', ->

	beforeEach( ->
		di = new DI
	)

	describe '#addService()', ->

		it 'should return instance of new Service class from object', ->
			expect(di.addService('array', Array)).to.be.an.instanceof(Service)

		it 'should return instance of new Service class from path', ->
			expect(di.addService('app', "#{dir}/Application")).to.be.an.instanceof(Service)

		it 'should throw an error if you try to register service with reserved name', ->
			expect( -> di.addService('di', DI)).to.throw(Error, "DI: name 'di' is reserved by DI.")

		it 'should create service with null as arguments', ->
			di.addService('http', "#{dir}/Http")
			di.addService('app', "#{dir}/Application", [null])
			expect(di.get('app').array).to.not.exists

	describe '#autowireArguments()', ->

		it 'should return array with services for Application', ->
			di.addService('array', Array)
			expect(di.autowireArguments(Application)).to.be.eql([[]])

		it 'should return array with services for inject method', ->
			di.addService('http', Http)
			args = di.autowireArguments((new Application([])).injectHttp)
			expect(args).to.have.length(1)
			expect(args[0]).to.be.an.instanceof(Http)

		it 'should return array with services for Application with custom ones', ->
			di.addService('info', ['hello']).setInstantiate(false)
			app = new Application([])
			expect(di.autowireArguments(app.prepare, ['simq'])).to.be.eql(['simq', ['hello']])

		it 'should throw an error if service to autowire does not exists', ->
			expect( -> di.autowireArguments(Application) ).to.throw(Error, "DI: Service 'array' was not found.")

		it 'should return array with services from params if they are not in definition', ->
			app = new Application([])
			expect(di.autowireArguments(app.withoutDefinition, ['hello'])).to.be.eql(['hello'])

		it 'should inject another service by at char', ->
			fn = (variable) -> return variable
			di.addService('array', Array)
			expect(di.autowireArguments(fn, ['@array'])).to.be.eql([[]])

		it 'should inject services replaced with dots in the end', ->
			fn = (first, second, third) -> return arguments
			di.addService('second', ['second item']).instantiate = false
			di.addService('third', ['third item']).instantiate = false
			expect(di.autowireArguments(fn, ['test', '...'])).to.be.eql(['test', ['second item'], ['third item']])

		it 'should inject services replaced with dots in the beginning', ->
			fn = (first, second, third) -> return arguments
			di.addService('first', ['first item']).instantiate = false
			di.addService('second', ['second item']).instantiate = false
			expect(di.autowireArguments(fn, ['...', 'test'])).to.be.eql([['first item'], ['second item'], 'test'])


	describe '#createInstance()', ->

		beforeEach( ->
			di.addService('array', Array)
			di.addService('http', Http)
		)

		it 'should return new instance of Application with all dependencies', ->
			app = di.createInstance(Application)
			expect(app).to.be.an.instanceof(Application)
			expect(app.array).to.be.an.instanceof(Array)
			expect(app.http).to.be.an.instanceof(Http)

		it 'should throw an error when service to inject does not exists', ->
			delete di.services.http
			expect( -> di.createInstance(Application)).to.throw(Error, "DI: Service 'http' was not found.")

	describe '#findDefinitionByName()', ->

		it 'should return definition of Array service', ->
			di.addService('array', Array)
			expect(di.findDefinitionByName('array')).to.be.an.instanceof(Service)

		it 'should throw an error if service is not registered', ->
			expect( -> di.findDefinitionByName('array')).to.throw(Error, "DI: Service 'array' was not found.")

	describe 'Loaders', ->

		beforeEach( ->
			di.addService('array', Array)
			di.addService('http', Http)
			di.addService('info', ['hello'])
				.setInstantiate(false)
			di.addService('noArray', ['not this one'])
				.setInstantiate(false)
				.setAutowired(false)
			di.addService('application', Application)
				.addSetup('prepare', ['simq', '...'])
		)

		describe '#get()', ->

			it 'should return instance of Application with all dependencies', ->
				app = di.get('application')
				expect(app).to.be.an.instanceof(Application)
				expect(app.namespace).to.be.equal('simq')
				expect(app.array).to.be.eql([])
				expect(app.http).to.be.an.instanceof(Http)

			it 'should return always the same instance of Application', ->
				expect(di.get('application')).to.be.equal(di.get('application'))

			it 'should return info array without instantiating it', ->
				expect(di.get('info')).to.be.eql(['hello'])

			it 'should not set services which are not autowired', ->
				di.findDefinitionByName('application')
					.addSetup('setData')
				expect( -> di.get('application')).to.throw(Error, "DI: Service 'noArray' in not autowired.")

			it 'should autowire di container into Application instance', ->
				di.findDefinitionByName('application')
					.addSetup('setDi')
				expect(di.get('application').di).to.be.equal(di)

			it 'should autowire di container factory into Application instance', ->
				di.findDefinitionByName('application')
					.addSetup('setDiFactory')
				factory = di.get('application').diFactory
				expect(factory).to.be.an.instanceof(Function)
				expect(factory()).to.be.equal(di)

			it 'should set info property directly', ->
				di.findDefinitionByName('application')
					.addSetup('info', 'by property')
				expect(di.get('application').info).to.be.equal('by property')

		describe '#create()', ->

			it 'should return always new instance of Application', ->
				expect(di.create('application')).to.not.be.equal(di.create('application'))

		describe '#getFactory()', ->

			it 'should return callable factory for Application', ->
				factory = di.getFactory('application')
				expect(factory).to.be.an.instanceof(Function)
				expect(factory()).to.be.an.instanceof(Application)

		describe '#inject()', ->

			it 'should inject some service into annonymous function', (done) ->
				di.addService('array', Array)
				di.inject( (array) ->
					expect(array).to.be.eql([])
					done()
				)

			it 'should throw an error if inject method is not called on function', ->
				expect( -> di.inject('')).to.throw(Error, "DI: Inject method can be called only on functions.")