require 'rubygems'
require 'bundler'

Bundler.setup
Bundler.require

require 'index'

run Sinatra::Application
