source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'google-cloud-translate'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.2'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
gem 'sidekiq'
gem 'sidekiq-failures', '~> 1.0'

gem 'jquery-rails', '~> 4.3'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'pundit'
gem 'pagarme'
gem 'country_state_select'

gem 'hotwire-rails'
gem 'turbo-rails'

gem 'rails-i18n', '~> 6.0.0'
gem 'devise-i18n'
gem "i18n-js"
gem 'translate_enum'

# Docx converters
gem 'caracal'
gem 'caracal-rails'
gem 'htmltoword'

gem 'gon'
gem 'pg_search'
# Use the money .format
gem 'money-rails', '~>1.12'
gem 'paper_trail'

gem 'client_side_validations'
gem 'client_side_validations-simple_form'

# error tracking
gem 'rollbar'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2'

gem 'devise'
gem 'cloudinary', '~> 1.16.0'
gem 'active_storage_validations'
gem 'docx'
gem 'devise_invitable', '~> 2.0.1'
gem 'letter_opener', group: :development

gem 'inline_svg'
gem 'kaminari'

gem 'autoprefixer-rails'
gem 'font-awesome-sass'
gem 'simple_form'
group :development, :test do
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'dotenv-rails'
  gem 'faker'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  # gem 'rack-test'
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'rails-controller-testing'
end

group :test, :development do
  gem 'launchy'
  gem "capybara-wsl"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'mocha', group: :test

gem "roo", "~> 2.8"
