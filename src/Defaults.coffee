isWindow = typeof window != 'undefined'

class Defaults


	constructor: (di) ->
		di.addService('di', di).setInstantiate(false)

		di.addService('timer', @getTimer()).setInstantiate(false)

		if isWindow
			di.addService('window', window).setInstantiate(false)
			di.addService('document', window.document).setInstantiate(false)
		else
			di.addService('global', global).setInstantiate(false)


	getTimer: ->
		main = if isWindow then window else global

		return {		# must be called with right context
			setTimeout: (callback, delay) -> main.setTimeout.apply(main, arguments)
			setInterval: (callback, delay) -> main.setInterval.apply(main, arguments)
			clearTimeout: (timeoutID) -> main.clearTimeout.call(main, timeoutID)
			clearInterval: (intervalID) -> main.clearInterval.call(main, intervalID)
		}


module.exports = Defaults