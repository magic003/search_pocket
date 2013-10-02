require 'sinatra/base'
require 'haml'

class SearchPocketApp < Sinatra::Base
  # version number
  VERSION = '0.0.1'

  enable :sessions
  set :haml, {:format => :html5, :layout => :layout }

  # Run this application
  run! if app_file == $0
end
