#!/usr/bin/env ruby

# This is the script that makes the delta index and merges it into the main
# index.
#
# Author::    Minjie Zha (mailto:minjiezha@gmail.com)
# Copyright:: Copyright (c) 2013-2014 Minjie Zha

require 'optparse'

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
  opts.banner = "Usage: indexer.rb [options]"

  opts.separator ""
  opts.separator "Options:"

  # Mandatory argument
  opts.on('-c', '--config CONFIG_FILE',
          'The Sphinx config file') do |conf|
    options[:config] = conf
  end

  opts.on_tail('-h', '--help',
               'Display this help message') do
    puts opts
    exit
  end

end.parse!

check_arguments!(options)

`indexer -c #{options[:config]} delta --rotate && indexer -c #{options[:config]} --merge main delta --rotate`
