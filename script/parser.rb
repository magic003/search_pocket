#!/usr/bin/env ruby

# This is the script that fetches the page content, parses its text content and
# saves it to database.
# 
# Author::    Minjie Zha (mailto:minjiezha@gmail.com)
# Copyright:: Copyright (c) 2013-2014 Minjie Zha

$:.unshift(File.dirname(__FILE__)+'/../lib') unless
  $:.include?(File.dirname(__FILE__)+'/../lib') || $:.include?(File.expand_path(File.dirname(__FILE__)+'/../lib'))

require 'optparse'
require 'open-uri'
require 'readability'
require 'logger'

require 'search_pocket'

$logger = Logger.new($stdout)

### function definitions ###

def check_arguments!(options)
  if options[:config].nil?
    puts "Error: no config file is provided."
    exit
  end
end

### end of function definition ###

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: parser.rb [options]"

  opts.separator ""
  opts.separator "Options:"

  # Mandatory argument
  opts.on('-c', '--config CONFIG_FILE',
          'Require the config file before executing this script') do |conf|
    options[:config] = conf
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

config = SearchPocket::Utils.config_file(options[:config], options[:env])
if config.nil?
  puts "Error: failed to load config file."
  exit
end

$logger = Logger.new(config['log_file'], 'monthly') if config['log_file']

db_config = config['db']
db = SearchPocket::Utils.sequel_connect("mysql2", db_config['username'],
                                         db_config['password'],
                                         db_config['host'],
                                         db_config['port'],
                                         db_config['database'])

Dir[File.join(File.expand_path(File.dirname(__FILE__)), "../app/models/*.rb")].each { |file| require file }

links = Link.where(status: 0)
links.each do |l|
  begin
    page = open(l.url).read
    doc = Readability::Document.new(page)
    l.set(content: doc.content, status: 1)
    title = l.given_title || l.resolved_title
    if title.nil? || title.empty?
      l.set(resolved_title: doc.title.strip)
    end
    l.save
  rescue Timeout::Error, Errno::ETIMEDOUT, Exception => e
    $logger.error "Warning: failed to parse link: #{l.url}"
    $logger.error e.to_s
    l.update(status: -1)
  end
end

SearchPocket::Utils.sequel_disconnect(db)
