require 'sinatra/base'
require 'haml'
require 'sinatra/config_file'
require 'omniauth'
require 'omniauth-pocket'
require 'sequel'

require_relative 'vendor/sphinx/sphinx'

class SearchPocketApp < Sinatra::Base
  # version number
  VERSION = '0.0.1'

  # application config file
  register Sinatra::ConfigFile
  config_file 'config/config.yml'

  enable :sessions
  set :views, ['views/layouts', 'views/pages', 'views/partials']
  set :haml, {:format => :html5, :layout => :layout }

  # include helpers
  Dir["./app/helpers/*.rb"].each { |file| require file }
  helpers ViewDirectoriesHelper, SessionHelper
  # include models
  db = settings.db
  Sequel.connect("mysql2://#{db[:username]}:#{db[:password]}@#{db[:host]}:#{db[:port]}/#{db[:database]}")
  Dir["./app/models/*.rb"].each { |file| require file }

  # use the omniauth-pocket middleware
  pocket = settings.pocket
  use OmniAuth::Builder do
    provider :pocket, pocket[:client_id], pocket[:client_secret]
  end

  # routers

  get '/' do
    if signed_in? 
      haml :search
    else # user not logged in
      haml :index
    end
  end

  get '/auth/:provider/callback' do
    uid = env['omniauth.auth'].uid
    token = env['omniauth.auth'].credentials.token   
    sign_in(uid)
    user = User[:name => uid]
    if user.nil? # it is a new user
      user = User.create({:name => uid, :token => token, :register_at => DateTime.now,
                          :login_at => DateTime.now})
      # spawn a process to retrieve and parse links
      pid = Process.spawn("script/crawler.rb -c config/config.yml -u #{user.name} "\
                          "&& script/parser.rb -c config/config.yml "\
                          "&& script/indexer.rb -c config/sphinx.conf",
                   :chdir => File.expand_path(File.dirname(__FILE__)))
      Process.detach(pid)
    else
      user.update({login_at: DateTime.now})
    end
    redirect to('/')
  end

  get '/auth/failure' do
    # TODO add a failure page
    haml "failed!"
  end

  get '/logout' do
    sign_out
    redirect to('/');
  end

  get '/search' do
    q = params[:q]
    if q.nil? || q.empty?
      haml :search
    else
      client = Sphinx::Client.new
      results = client.Query(q)
      haml results['total'].to_s
    end
  end

  # Run this application
  run! if app_file == $0
end
