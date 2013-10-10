require 'readability'
require 'open-uri'

page = open('http://www.36kr.com/p/205109.html').read
doc = Readability::Document.new(page, :tags => ['div'])
puts doc.content
