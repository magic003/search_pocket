$:.unshift(File.dirname(__FILE__) + '/../lib') unless
  $:.include?(File.dirname(__FILE__) + '/../lib') || $:.include?(File.expand_path(File.dirname(__FILE__) + '/../lib'))

require 'minitest/autorun'
require 'logger'
require 'yaml'

require 'sp'

# Load the config file for tests.
def load_config
  SP.config_file(File.expand_path('../fixtures/config.yml', __FILE__), 'test')
end

# Connect to database and require Sequel models
def require_models
  cfg = load_config()['db']
  db = SP.sequel_connect('mysql2', cfg['username'], cfg['password'],
                         cfg['host'], cfg['port'], cfg['database'])
  Dir[File.join(File.expand_path('../../app/models/*.rb', __FILE__))].each do 
    |f|
    require f
  end
end

# Create a logger using stdout.
def default_logger
  Logger.new($stdout)
end

# Get a default env with logger and config
def default_env
  {'sp.config' => load_config, 'sp.logger' => default_logger}
end

# Get the user for testing.
def default_user
  yaml = YAML.load(File.open(File.expand_path('../fixtures/user.yml', __FILE__)))
  u = yaml['user1']
  User.create({name: u['name'], token: u['token']})
end

# Get links for testing.
def test_links
  yaml = YAML.load(File.open(File.expand_path('../fixtures/links.yml', __FILE__)))
  links = []
  yaml['links'].each do |l|
    links << Link.new(l)
  end
  links
end
