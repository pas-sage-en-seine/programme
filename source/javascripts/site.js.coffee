class TimeTable
	constructor: (@element) ->

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
		Math.round top

	position: (times, element) ->
		from = @parse_time element.dataset.from
		to = @parse_time element.dataset.to

		including_from = @find_including times, from
		including_to = @find_including times, to

		top = @prorate including_from, from
		bottom = @prorate including_to, to

		root = element.parentElement
		width = root.clientWidth

		element.style.top = "#{top}px"
		element.style.height = "#{bottom - top}px"
		element.style.width = "#{width}px"
		element.style.position = 'absolute'

	init: ->
		times = []

		hours = @element.querySelectorAll 'tbody td:first-child li'
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

		events = @element.querySelectorAll 'tbody td:not(:first-child) li'
		for event in events
			@position times, event

init = ->
	tables = document.querySelectorAll 'table.timetable'
	for table in tables
		new TimeTable(table).init()


document.addEventListener 'DOMContentLoaded', init
window.addEventListener 'resize', init



