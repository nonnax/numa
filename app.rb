#!/usr/bin/env ruby
# Id$ nonnax 2022-04-25 22:40:25 +0800
require_relative 'lib/numa'

Numa.settings[:layout]='layout_001'

$sum = 0

Thread.new do # trivial example work thread
  loop do
     sleep 0.12
     $sum += 1
  end
end

TV = Numa.new do
  # prefer small app for modular composition
  get do
    on '/tv' do |params|
      session[:name]='TeeVee'
      erb 'watch:tv:'+String(session[:name])+String(params), title: 'tv time'
    end
  end
end

Admin = Numa.new do
  on( '/login', name:'nald', surname:'') do |name, sur|
    session[:name]=name
    erb 'welcome:'+String(session[:name])+String(sur), title: 'welcome'
  end
end

App = Numa.new do
  #
  # path test first
  #
  on '/thread' do
    res.write "Testing background work thread: sum is #{$sum}"
  end

  on '/tv' do
    # transfer control to external app
    halt TV
  end
  #
  # method first test
  # url with slug. ie /url/:slug
  get do
    on '/any/:slug', default: 'default' do |slug, params|
      erb 'watch:'+String(slug)+String(params), title: 'movie time'
    end

  end
  # session test
  # on( '/login', name:'', surname:'') do |name, sur|
  on '/login', name: 'numa' do
    halt Admin
  end

  #
  # method with url test. numb.rb only
  #
  # get '/all' do |all|
     # erb 'watch:all'+String(all), title: 'all time'
  # end
  #
  # test position in prog flow
  #
  on '/' do
    res.redirect '/thread'
  end

  default do
    erb 'notto foundo'
  end
end
