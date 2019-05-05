class TimeTable
	constructor: (@element, @modal) ->
		events = @element.querySelectorAll 'tbody td > div'
		for event in events
			# JS scoping hell…
			event.addEventListener 'click', ((_this, _event) ->
				-> _this.modal.open _event
			)(this, event)

	init: () ->

class Modal
	size: { width: 800, height: 480 }

	constructor: (@modal) ->
		@header = @modal.querySelector '.header'
		@body = @modal.querySelector '.body'
		@modal.querySelector('.close').addEventListener 'click', @close
		@modal.querySelector('.cover').addEventListener 'click', @close

	act: (events) ->
		wrapper = =>
			next = events.shift()
			return unless next?
			[duration, callback] = next
			setTimeout (=>
				callback()
				wrapper()
			), duration
		wrapper()

	start: ->
		start = @event.getBoundingClientRect()
		scroll = {
			top: window.pageYOffset,
			left: window.pageXOffset
		}

		@modal.style.top = "#{start.top + scroll.top}px"
		@modal.style.left = "#{start.left + scroll.left}px"
		@modal.style.width = "#{start.width}px"
		@modal.style.height = "#{start.height}px"
		@header.style.width = "#{start.width}px"
		@header.style.height = "#{start.height}px"
		@body.style.width = 0
		@body.style.height = "#{start.height}px"

	open: (@event) ->
		scroll = {
			top: window.pageYOffset,
			left: window.pageXOffset
		}

		modal =
			width: Math.round window.innerWidth * .8
			height: Math.round window.innerHeight * .8
		modal =
			width: Math.min modal.width, @size.width
			height: Math.min modal.height, @size.height
		modal.top = Math.round (window.innerHeight - modal.height) / 2 + scroll.top
		modal.left = Math.round (window.innerWidth - modal.width) / 2 + scroll.left

		header_width = Math.round modal.width / 3

		time = @event.querySelector('.time').textContent
		@header.querySelector('.time').textContent = time
		title = @event.querySelector('.title').textContent
		@header.querySelector('.title').textContent = title
		author = @event.querySelector('.author').textContent
		@header.querySelector('.author').textContent = author
		description = @event.querySelector('.description').innerHTML
		@body.innerHTML = ''

		@modal.classList.remove 'transition'
		@act [
			[20, =>
				@start()
				@header.classList = @event.classList
				@header.classList.add 'header'
				@modal.style.opacity = 1
				@modal.classList.remove 'hidden'
			],
			[20, =>
				@transition @modal, null, =>
					@body.innerHTML = description

				@modal.style.top = "#{modal.top}px"
				@modal.style.left = "#{modal.left}px"
				@modal.style.width = "#{modal.width}px"
				@modal.style.height = "#{modal.height}px"
				@header.style.width = "#{header_width}px"
				@header.style.height = "#{modal.height}px"
				@body.style.width = "#{modal.height - header_width}px"
				@body.style.height = "#{modal.height}px"
			]
		]

	close: =>
		@act [
			[20, =>
				@transition @modal, null, =>
					@modal.classList.add 'hidden'

				@body.innerHTML = ''
				@start()
			]
		]

	transition: (element, events, at_end) ->
		element.classList.add 'transition'

		callback = ->
			element.removeEventListener 'transitionend', callback
			element.classList.remove 'transition'
			at_end() if at_end?

		element.addEventListener 'transitionend', callback
		@act events if events?

class Giggity
	@init: ->
		giggity_logo = document.querySelector '.giggity .logo'
		position = giggity_logo.getBoundingClientRect()
		giggity_qrcode = document.querySelector '.giggity .qrcode'
		giggity_qrcode.style.top = "#{position.bottom + 20}px"
		giggity_qrcode.style.left = "#{position.right + 20}px"

		giggity_logo.addEventListener 'mouseenter', ->
			giggity_qrcode.classList.remove 'hidden'
		giggity_logo.addEventListener 'mouseleave', ->
			giggity_qrcode.classList.add 'hidden'


init = ->
	modal = new Modal document.querySelector '.modal'

	tables = document.querySelectorAll 'table.timetable'
	for table in tables
		new TimeTable(table, modal).init()

	Giggity.init()


document.addEventListener 'DOMContentLoaded', init
window.addEventListener 'resize', init
