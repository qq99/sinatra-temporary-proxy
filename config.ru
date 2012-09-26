#ENV['GEM_PATH'] = "#{ENV['HOME']}/gems:/usr/lib/ruby/gems/1.8"
ENV['GEM_HOME'] = "#{ENV['HOME']}/gems"

require 'rubygems'
require 'sinatra'
require 'sass'
require 'haml'

set :env,  :production
disable :run

require 'app'
