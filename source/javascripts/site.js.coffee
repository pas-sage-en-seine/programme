class TimeTable
	constructor: (@element, @modal, @navigation) ->
		events = @element.querySelectorAll 'tbody td .event__toggleBtn'
		for event in events
			# JS scoping hell…
			event.addEventListener 'click', ((_this, _event) ->
				-> _this.modal.open _event
			)(this, event)

		btnsSelect = @navigation.querySelectorAll '.navigation__select'
		for btn in btnsSelect
		# JS scoping hell…
			btn.addEventListener 'click', ((_thisbtn, _eventbtn) ->
				-> _thisbtn.displayDay _eventbtn
			)(this, btn)

	init: () ->
		window.addEventListener 'resize', @displayDay()
		@displayDay();

	hideOtherDays: (day) ->
			toRemoveClass = document.querySelectorAll ".navigation__item:not(:nth-of-type(#{ day })) .navigation__select"
			toHide = document.querySelectorAll "td:not([data-col='#{ day }']), th:not([data-col='#{ day }'])";
			toHideCol = document.querySelectorAll "colgroup:not(:nth-of-type(#{ Number(day) + 1 })";

			for hide in toHide
				hide.style.display = 'none'

			for col in toHideCol
				col.style.display = 'none'

			for remove in toRemoveClass
				remove.classList.remove('navigation__select--selected');
				remove.setAttribute('aria-expanded', false);


	selectDay: (day) ->
		document.querySelector(".navigation__item:nth-of-type(#{ day }) .navigation__select").classList.add "navigation__select--selected";
		document.querySelector(".navigation__item:nth-of-type(#{ day }) .navigation__select").setAttribute("aria-expanded", true);
		document.querySelector("colgroup:nth-of-type(#{ Number(day) + 1 })").style.display = 'table-column-group';
		toShow = document.querySelectorAll "td[data-col='#{ day }'], td[data-col='#{ Number(day) + 1 }'], th[data-day='#{ day }']";
		for show in toShow
			show.style.display = 'table-cell'

	displayAllDays: () ->
		toShow = document.querySelectorAll "td, th";
		for show in toShow
			show.style.display = 'table-cell'


	displayDay: (btn) ->
		if window.innerWidth > 1200
			@displayAllDays()
			return

		day = 1;
		if (btn)
			day = btn.getAttribute('data-day')

		@hideOtherDays(day);
		@selectDay(day) 	# TODO: (IMPROVEMENT) TEST IF CURRENT DAY === ONE DAY of the EVENT

class Modal
	size: { width: 800, height: 480 }

	constructor: (@modal) ->
		@header = @modal.querySelector '.header'
		@body = @modal.querySelector '.body'
		@modal.querySelector('.close').addEventListener 'click', @close
		@modal.querySelector('.cover').addEventListener 'click', @close
		@originFocus = undefined;

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

		@originFocus = @event;
		@modal.querySelector('.close').focus()

		time = @event.parentElement.querySelector('.time').textContent
		@header.querySelector('.time').textContent = time
		type = @event.parentElement.querySelector('.type').textContent
		@header.querySelector('.type').textContent = type
		place = @event.parentElement.getAttribute('data-place')
		@header.querySelector('.place').textContent = place
		title = @event.parentElement.querySelector('.title').getAttribute('data-fullTitle')
		@header.querySelector('.title').textContent = title
		author = @event.parentElement.querySelector('.author').textContent
		@header.querySelector('.author').textContent = author
		description = @event.parentElement.querySelector('.description').innerHTML
		@body.innerHTML = ''

		@modal.classList.remove 'transition'
		@act [
			[20, =>
				@start()
				@header.classList = @event.parentElement.classList
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
				@originFocus.focus()
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


init = ->
	modal = new Modal document.querySelector '.modal'
	navigation = document.querySelector '.navigation'

	tables = document.querySelectorAll 'table.timetable'
	for table in tables
		new TimeTable(table, modal, navigation).init()

	Giggity.init()


document.addEventListener 'DOMContentLoaded', init
window.addEventListener 'resize', init
