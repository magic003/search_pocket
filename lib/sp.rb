require 'sp/utils'
require 'sp/fixed_thread_pool'
require 'sp/middleware'

require 'yaml'
require 'sequel'

module SP
  # Loads the config settings based on environment.
  def self.config_file(path, env)
    yaml = YAML::load(File.open(path))
    yaml[env.to_s]   
  end

  # Create a sequel database connection
  def self.sequel_connect(adapter, user, passwd, host, port, db)
    url = "#{adapter}://"
    url << user unless user.nil?
    url << ":#{passwd}" unless passwd.nil?
    url << "@#{host}"
    url << ":#{port}" unless port.nil?
    url << "/#{db}"
    Sequel.connect(url)
  end

  # Disconnect all sequel connections
  def self.sequel_disconnect(db)
    db.disconnect
  end
end
