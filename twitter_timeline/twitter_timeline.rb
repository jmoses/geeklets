#!/usr/bin/env ruby

require 'rubygems'
require 'twitter'

class ConfigStore
  attr_reader :file
  
  def initialize(file)
    @file = file
  end
  
  def load
    @config ||= File.exists?(file) ? (YAML::load(open(file)) or {}) : {}
    self
  end
  
  def [](key)
    load
    @config[key]
  end
  
  def []=(key, value)
    @config[key] = value
  end
  
  def delete(*keys)
    keys.each { |key| @config.delete(key) }
    save
    self
  end
  
  def update(c={})
    @config.merge!(c)
    save
    self
  end
  
  def save
    File.open(file, 'w') { |f| f.write(YAML.dump(@config)) }
    self
  end
end

config = ConfigStore.new("#{ENV['HOME']}/.twitter")
oauth = Twitter::OAuth.new( config['token'], config['secret'] )

twitter = nil

if config['atoken'] && config['asecret']
  oauth.authorize_from_access(config['atoken'], config['asecret'])
  twitter = Twitter::Base.new(oauth)
elsif config['rtoken'] && config['rsecret']  
  oauth.authorize_from_request(config['rtoken'], config['rsecret'], config['pin'])
  twitter = Twitter::Base.new(oauth)
  config.update({
    'atoken'  => oauth.access_token.token,
    'asecret' => oauth.access_token.secret,
  }).delete('rtoken', 'rsecret')
else
  config.update({
    'rtoken'  => oauth.request_token.token,
    'rsecret' => oauth.request_token.secret,
  })
  
  # authorize in browser
  `open #{oauth.request_token.authorize_url}`
  
  print "Enter your pin: "
  pin = gets
  config.update({'pin' => pin.strip})
  puts "OK!"
end

if twitter
  twitter.home_timeline(:count => 10).each do |tweet|
    printf("%s - %s: %s\n", Time.parse(tweet.created_at).strftime("%H:%M"), tweet.user.name, tweet.text)
  end
end