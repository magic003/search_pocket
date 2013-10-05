require 'sinatra/base'
require 'haml'
require 'sinatra/config_file'
require 'omniauth'
require 'omniauth-pocket'

Dir["./app/helpers/*.rb"].each { |file| require file }

class SearchPocketApp < Sinatra::Base
  # version number
  VERSION = '0.0.1'

  register Sinatra::ConfigFile

  config_file 'config/config.yml'

  enable :sessions
  set :views, ['views/layouts', 'views/pages', 'views/partials']
  set :haml, {:format => :html5, :layout => :layout }

  helpers ViewDirectoriesHelper

  pocket = settings.pocket
  use OmniAuth::Builder do
    provider :pocket, pocket[:client_id], pocket[:client_secret]
  end

  get '/' do
    haml :index
  end

  get '/auth/:provider/callback' do |p|
    haml :search
  end

  get '/auth/failure' do
    haml "failed!"
  end

  # Run this application
  run! if app_file == $0
end
