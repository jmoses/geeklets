#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'hpricot'

doc = Hpricot( open("http://weather.yahoo.com/united-states/vermont/-12759989/") )

icon = doc.at("div#yw-forecast > .forecast-icon")
style = icon.attributes['style']

if style =~ /url\('(.*?)'\)/
  File.open('/tmp/weather.png', 'w') {|out| open($1) {|f| out << f.read } }
end