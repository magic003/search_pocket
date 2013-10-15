#!/usr/bin/env ruby

# This is the script that makes the delta index and merges it into the main
# index.
#
# Author::    Minjie Zha (mailto:minjiezha@gmail.com)
# Copyright:: Copyright (c) 2013-2014 Minjie Zha

$:.unshift(File.dirname(__FILE__)+'/../lib') unless
  $:.include?(File.dirname(__FILE__)+'/../lib') || $:.include?(File.expand_path(File.dirname(__FILE__)+'/../lib'))

require 'optparse'
require 'logger'

require 'search_pocket'

$logger = Logger.new($stdout)

### function definitions ###

def check_arguments!(options)
  if options[:config].nil?
    puts "Error: no SearchPocket config file is provided."
    exit
  end

  if options[:sphinx].nil?
    puts "Error: no Sphinx config file is provided."
    exit
  end
end

### end of function definition ###

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: indexer.rb [options]"

  opts.separator ""
  opts.separator "Options:"

  # Mandatory argument
  opts.on('-c', '--config CONFIG_FILE',
          'The SearchPocket config file') do |conf|
    options[:config] = conf
  end

  opts.on('-s', '--sphinx-config CONFIG_FILE',
          'The Sphinx config file') do |conf|
    options[:sphinx] = conf
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
  $logger.error "Error: failed to load config file."
  exit
end

$logger = Logger.new(config['log_file'], 'weekly') if config['log_file']

$logger.info "Starting indexing"

output = `(indexer -c #{options[:sphinx]} delta --rotate && sleep 5 && indexer -c #{options[:sphinx]} --merge main delta --rotate) 2>&1`
if $? == 0
  $logger.info output
else
  $logger.error output
end

$logger.info "Indexed"
