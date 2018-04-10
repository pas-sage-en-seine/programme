activate :sprockets
activate :i18n, mount_at_root: :fr
activate :autoprefixer do |prefix|
	prefix.browsers = 'last 2 versions'
end

configure :development do
	activate :livereload, apply_css_live: true, apply_js_live: true, no_swf: true
end

configure :build do
	set :relative_links, true
	activate :relative_assets
	activate :minify_css
	activate :minify_javascript
end
