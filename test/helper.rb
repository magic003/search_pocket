$:.unshift(File.dirname(__FILE__) + '/../lib') unless
  $:.include?(File.dirname(__FILE__) + '/../lib') || $:.include?(File.expand_path(File.dirname(__FILE__) + '/../lib'))

require 'minitest/autorun'
require 'sp'
