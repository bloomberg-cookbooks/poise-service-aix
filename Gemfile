#
# Cookbook: poise-service-aix
# License: Apache 2.0
#
# Copyright 2015, Noah Kantrowitz
# Copyright 2015-2017, Bloomberg Finance L.P.
#

source 'https://rubygems.org/'

gemspec path: File.expand_path('..', __FILE__)

def dev_gem(name, path: File.join('..', name), github: nil)
  path = File.expand_path(File.join('..', path), __FILE__)
  if File.exist?(path)
    gem name, path: path
  elsif github
    gem name, git: "https://github.com/#{github}.git"
  end
end

dev_gem 'halite'
dev_gem 'poise-boiler', github: 'poise/poise-boiler'
dev_gem 'poise-profiler'
