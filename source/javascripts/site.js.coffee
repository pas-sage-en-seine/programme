class TimeTable
	constructor: (@element, @modal) ->
		events = @element.querySelectorAll 'tbody td li'
		for event in events
			# JS scoping hell…
			event.addEventListener 'click', ((_this, _event) ->
				-> _this.modal.open _event
			)(this, event)

	parse_time: (time) ->
		time = time.split ':'
		hour = parseInt time[0]
		min = parseInt time[1]
		60 * hour + min

	find_including: (times, time) ->
		previous = null
		for current in times
			if previous?
				if previous.time <= time < current.time
					return [previous, current]
			else
				previous = current
		null

	prorate: (ref, time) ->
		from = ref[0]
		to = ref[1]

		ratio = (time - from.time) / (to.time - from.time)
		top = from.top + (to.top - from.top) * ratio
		top

	position: (times, element) ->
		from = @parse_time element.dataset.from
		to = @parse_time element.dataset.to

		including_from = @find_including times, from
		including_to = @find_including times, to

		top = @prorate including_from, from
		bottom = @prorate including_to, to

		root = element.parentElement
		width = root.offsetWidth

		element.style.top = "#{top + window.pageYOffset}px"
		element.style.height = "#{bottom - top}px"
		element.style.width = "#{width}px"
		element.style.position = 'absolute'

	init: ->
		times = []

		hours = @element.querySelectorAll 'tbody th li'
		for hour in hours
			time = @parse_time hour.dataset.time
			times.push {
				time: time,
				top: hour.getBoundingClientRect().top
			}
		last = hours[hours.length - 1]
		time = @parse_time last.dataset.time
		rect = last.getBoundingClientRect()
		times.push {
			time: time + 60
			top: rect.top + rect.height
		}

		events = @element.querySelectorAll 'tbody td li'
		for event in events
			@position times, event

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


init = ->
	modal = new Modal document.querySelector '.modal'

	tables = document.querySelectorAll 'table.timetable'
	for table in tables
		new TimeTable(table, modal).init()

document.addEventListener 'DOMContentLoaded', init
window.addEventListener 'resize', init
