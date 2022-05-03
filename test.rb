#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-24 19:13:24 +0800
require 'rack'
require 'rack/test'
require 'test/unit'

OUTER_APP = Rack::Builder.parse_file('config.ru').first

class TestApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  def test_root
    get '/'
    # assert last_response.ok?
    assert_equal last_response.status, 302
  end

  def test_root_post
    post '/'
    # assert last_response.ok?
    assert_equal last_response.status, 302
  end

  def test_login_session_get
    get '/login', name: 'nonnax'
    assert_equal last_response.status, 200
    assert last_response.body.include?('nonnax')
  end

  def test_login_post
    post '/login/name'
    assert_equal last_response.status, 404 # no method
  end

  def test_normal
    get '/tv'
    assert_equal last_response.status, 200
  end

  # numb.rb only
  # def test_method_with_urls
    # get '/all'
    # assert_equal last_response.status, 200
  # end

  # def test_method_with_url_with_params
    # get '/all', arg:'arg'
    # assert_equal last_response.status, 200
    # assert last_response.body.include?('arg')
  # end

  def test_any
    get '/any/any', options: 'default'
    assert last_response.ok?
    assert_equal last_response.status, 200
    assert last_response.body.match?('default')
    assert last_response.body.match?('any')
  end

  def test_not_found
    get '/adgads/asdfa'
    assert_equal last_response.status, 404
    # assert_equal last_response.body, 'notto foundo'
  end
  def test_outer_app
    get '/inner'
    assert_equal last_response.status, 200
  end
end
