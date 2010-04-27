#!/bin/env ruby

require 'rubygems'
require 'net/http'
require 'hpricot'
require 'uri'
require 'time'
require 'facets/date'

BASE_URL = "http://www.pivotaltracker.com/services/v3/"
HEADERS = {"X-TrackerToken", '8c0854bc59d8320f5140ac129172c23b'}

def get( url )
  begin
    url = URI.parse( BASE_URL + url )
    result = Net::HTTP.start( url.host, url.port ) do |http|
      http.get( url.path, HEADERS )
    end.body
    
    Hpricot(result)
  rescue
    STDERR.puts("Error fetching #{url}")
    STDERR.puts $!.class.name + ': ' + $!.message
    STDERR.puts $!.backtrace.join("\n")
    ""
  end
end

puts "Fetching activities..."
(get('activities')/'activity').each do |act|
  occurred_at = Time.parse( act.at("occurred_at").inner_text )
  
  if (Date.today.to_datetime.beginning_of_day .. Date.today.to_datetime.end_of_day).include?( occurred_at.to_datetime )
    occurred_at = occurred_at.strftime("today at %H:%M")
  else
    occurred_at = occurred_at.strftime("%Y-%m-%d %H:%M")
  end
  
  print occurred_at + '/'
  
  case act.at("event_type").inner_text
  when 'story_create'
    puts act.at("description").inner_text
  when 'story_update'
    puts act.at("description").inner_text
  when 'note_create'
    puts act.at("description").inner_text
  else
    puts "Don't know how to output #{act.at('event_type').inner_text} activities"
    puts act.to_s
  end
  puts " #{act.at("stories story url").inner_text}"
  puts
end
