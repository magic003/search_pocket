require 'sinatra/base'
require 'haml'

Dir["./app/helpers/*.rb"].each { |file| require file }

class SearchPocketApp < Sinatra::Base
  # version number
  VERSION = '0.0.1'

  enable :sessions
  set :views, ['views/layouts', 'views/pages', 'views/partials']
  set :haml, {:format => :html5, :layout => :layout }

  helpers ViewDirectoriesHelper

  get '/' do
    haml :index
  end

  # Run this application
  run! if app_file == $0
end
