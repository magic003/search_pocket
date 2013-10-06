#!/usr/bin/env ruby

# This is the script that retrieves links from Pocket. It can run for either
# a list of specific users or all signed up users.
#
# Author::    Minjie Zha (mailto:minjiezha@gmail.com)
# Copyright:: Copyright (c) 2013-2014 Minjie Zha

require 'optparse'
require 'yaml'
require 'sequel'

### function definitions ###

def check_arguments!(options)
  if options[:config].nil?
    puts "Error: no config file is provided."
    exit
  end
end

def load_config_file(options)
  yaml = YAML::load(File.open(options[:config]))
  yaml[options[:env]]
end

def connect_db(db_config)
  Sequel.connect("mysql2://#{db_config['username']}:#{db_config['password']}@#{db_config['host']}:#{db_config['port']}/#{db_config['database']}")
end

def require_models()
  Dir[File.join(File.expand_path(File.dirname(__FILE__)), "../app/models/*.rb")].each { |file| require file }
end

def disconnect_db(db)
  db.disconnect
end

def retrieve_links_by_user(user, options)
  puts user.name
end

def retrieve_links(options, config)
  names = options[:users]
  users = (names.nil? || names.empty?) ? User.all : User.where(:name => names)

  users.each do |user|
    retrieve_links_by_user(user, options)
  end
end

## end of function definitions ###

# Program entry

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: crawler.rb [options]"

  opts.separator ""
  opts.separator "Options:"

  # Mandatory argument
  opts.on('-c', '--config CONFIG_FILE',
          'Require the config file before executing this script') do |conf|
    options[:config] = conf
  end

  opts.on('-u', '--users user1,user2,userN', Array,
          'Users whose links are to be crawled. All signed up users if not specified.') do |users|
    options[:users] = users
  end

  options[:env] = 'development'
  opts.on('-e', '--env ENVIRONMENT',
          'Runtime environment for executing this script') do |env|
    options[:env] = env
  end

  opts.on_tail('-h', '--help',
               'Display this help message') do
    puts opts
    exit
  end

end.parse!

check_arguments!(options)

config = load_config_file(options)
if config.nil?
  puts "Error: failed to load config file."
  exit
end

db = connect_db(config['db'])
require_models()

retrieve_links(options, config)

disconnect_db(db)
