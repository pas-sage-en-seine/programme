activate :sprockets
activate :i18n, mount_at_root: :fr

configure :development do
	activate :livereload, apply_css_live: true, apply_js_live: true, no_swf: true if defined? Livereload
end

configure :build do
#	set :relative_links, true
#	activate :relative_assets
	activate :minify_css
	activate :minify_javascript
end

activate :deploy do |deploy|
	deploy.build_before = true
	deploy.deploy_method = :rsync
	deploy.host = 'rabbit.passageenseine.fr'
	deploy.port = 2222
	deploy.path = '/var/www/programme'
end
