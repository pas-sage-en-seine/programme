#!/usr/bin/env ruby
require 'awesome_print'
require 'action_mailer'

I18n.load_path = Dir['locale/*.yml']
I18n.available_locales         = %i[fr]
I18n.default_locale            = :fr
I18n.enforce_available_locales = false

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method       = :smtp
ActionMailer::Base.smtp_settings         = {
		address: 'localhost',
		# port:    1025,
		openssl_verify_mode: 'none'
}
ActionMailer::Base.view_paths            = File.dirname(__FILE__)

class Mailer < ActionMailer::Base
	def notify(to, events)
		puts "Notify #{to} with #{events.size} events"
		@events = events
		mail from:    'conferences@passageenseine.fr',
			 to:      to,
			 # to:      ['aeris@imirhil.fr', 'dashcom@protonmail.com'],
			 subject: '[PSES] Conférence retenue'
	end
end

TYPES = {
		talks:     'Conférence',
		workshops: 'Atelier'
}.freeze

planning = YAML.load File.read 'config/2018.yml'
events   = []
planning.each do |date, ess|
	ess.each do |type, es|
		es.each do |e|
			email = e[:email]
			next unless email
			events << {
					email: email,
					type:  TYPES[type.to_sym],
					title: e[:title],
					date:  date,
					from:  e[:from],
					to:    e[:to]
			}
		end
	end
end
events = events.group_by { |e| e[:email] }.to_h

events.each do |to, events|
	Mailer.notify(to, events).deliver
	# break
end
