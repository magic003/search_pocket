#!/usr/bin/env ruby

# This is the script that runs the links bootstrap for one or a set of users.
# It retrieves links from Pocket, parses the web pages and creates index.
#
# Author::    Minjie Zha (mailto:minjiezha@gmail.com)
# Copyright:: Copyright (c) 2014-2015 Minjie Zha

$:.unshift(File.dirname(__FILE__)+'/../lib') unless
  $:.include?(File.dirname(__FILE__)+'/../lib') || $:.include?(File.expand_path(File.dirname(__FILE__)+'/../lib'))

require 'optparse'

require 'sp'

### function definitions ###

def check_arguments!(options)
  if options[:config].nil?
    puts "Error: no config file is provided."
    exit
  end
end

## end of function definitions ###

# Program entry

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: bootstrap.rb [options]"

  opts.separator ""
  opts.separator "Options:"

  # Mandatory argument
  opts.on('-c', '--config CONFIG_FILE',
          'Require the config file before executing this script') do |conf|
    options[:config] = conf
  end

  opts.on('-s', '--sphinx-config CONFIG_FILE',
          'The Sphinx config file') do |conf|
    options[:sphinx] = conf
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

  opts.on('-b', '--bootstrap', 'Retrieve links for a new user') do
    options[:bootstrap] = true
  end

  opts.on_tail('-h', '--help',
               'Display this help message') do
    puts opts
    exit
  end

end.parse!

check_arguments!(options)

config = SP.config_file(options[:config], options[:env])
db_config = config['db']

# connect to database and load models
db = SP.sequel_connect("mysql2", db_config['username'],
                                       db_config['password'],
                                       db_config['host'],
                                       db_config['port'],
                                       db_config['database'])

Dir[File.join(File.expand_path(File.dirname(__FILE__)), "../app/models/*.rb")].each { |file| require file }

# create app
app = SP::Builder.new do
  use SP::Config, options[:config]
  use SP::Logger
  use SP::LegacyLinksLoader unless options[:bootstrap]
  use SP::PocketLinksRetriever
  use SP::Batcher, 50 if options[:bootstrap]
  use SP::PageParser
  use SP::Indexer, options[:sphinx]
end

env = {'SP_ENV' => options[:env]}
names = options[:users]
env['sp.users'] = (names.nil? || names.empty?) ? User.all : User.where(:name => names)

app.call(env)

SP.sequel_disconnect(db)
