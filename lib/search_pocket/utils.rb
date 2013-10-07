require 'yaml'
require 'sequel'

module SearchPocket ; module Utils
  # Loads the specific envrionment settings for the config file.
  def self.config_file(path, env)
    yaml = YAML::load(File.open(path))
    yaml[env.to_s]
  end

  # Create a sequel database connection
  def self.sequel_connect(adapter, user, password, host, port, database)
    url = "#{adapter}://"
    url << user unless user.nil?
    url << ":#{password}" unless password.nil?
    url << "@#{host}"
    url << ":#{port}" unless port.nil?
    url << "/#{database}"
    Sequel.connect(url)
  end

  # Disconnect all sequel connections
  def self.sequel_disconnect(db)
    db.disconnect
  end

end ; end
