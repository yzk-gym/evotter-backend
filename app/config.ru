require 'rack'
require 'rack/contrib'
require_relative './app'

set :root, File.dirname(__FILE__)
set :views, Proc.new { File.join(root, "views") }

run Sinatra::Application