require 'rubygems'
require 'nokogiri'
require 'csv'
if CSV.const_defined? :Reader
  require 'fastercsv'
end

module Dfxml
end

require 'dfxml/saxreader'