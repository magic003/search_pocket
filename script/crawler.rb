#!/usr/bin/env ruby

# This is the script that retrieves links from Pocket. It can run for either
# a list of specific users or all signed up users.
#
# Author::    Minjie Zha (mailto:minjiezha@gmail.com)
# Copyright:: Copyright (c) 2013-2014 Minjie Zha

require 'optparse'
require 'yaml'
require 'sequel'
require 'net/http'
require 'uri'
require 'json'

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

def retrieve_links_by_user(user, config)
  uri = URI('https://getpocket.com/v3/get')
  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
    req = Net::HTTP::Post.new(uri.request_uri,
                             initheader={'Content-Type' => 'application/json'})
    payload = { 'consumer_key' => config['pocket']['client_secret'],
                'access_token' => user.token,
                'state' => 'all'
              }
    payload['since'] = user.since unless user.since.nil?
    req.body = payload.to_json
    http.request(req)
  end

  if res.code.to_i == 200
    json = JSON.parse(res.body)
    if json['list'].size > 0
      json['list'].each_value do |item|
        Link.find_or_create(item_id: item['item_id']) do |l|
          l.url = item['resolved_url'] || item['given_url']
          l.given_title = item['given_title']
          l.resolved_title = item['resolved_title']
          l.favorite = item['favorite'].to_i
          l.excerpt = item['excerpt']
          l.user_id = user.id
        end
      end
    end
    user.update(since: json['since'])
  end
end

def retrieve_links(options, config)
  names = options[:users]
  users = (names.nil? || names.empty?) ? User.all : User.where(:name => names)

  users.each do |user|
    retrieve_links_by_user(user, config)
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
