#!/usr/bin/env ruby

require 'open-uri'
require 'uri'
require 'rss/1.0'
require 'rss/2.0'

class Time
  def distance_ago_in_words
    seconds = (Time.now - self).to_i
    
    minutes = seconds / 60
    hours = ( seconds / 3600 )
    days = ( seconds / 86400 )
    
    if days > 0
      "#{days} days ago"
    elsif hours > 0
      "#{hours} hours ago"
    elsif minutes > 0
      "#{minutes} minutes ago"
    else
      "now"
    end
  end
end

url = "http://ws.audioscrobbler.com/1.0/user/#{ENV['user']}/recenttracks.rss"

rss = RSS::Parser.parse(open(url) {|r| r.read }, false)


last_items = [10, rss.items.size].min

last_items.times do |i| item = rss.items.reverse[i]

  puts "#{item.title} (#{item.date.distance_ago_in_words})"

end


