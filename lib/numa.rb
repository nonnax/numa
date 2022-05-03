#!/usr/bin/env ruby
# Id$ nonnax 2022-04-30 11:09:50 +0800
# notta unified mapper, boom!
require_relative 'numv'

class Numa
  H = Hash.new{|h,k|h[k] = k.transform_keys(&:to_sym)}
  class Response < Rack::Response; end

  attr :req, :res, :env

  def initialize(&block)
    @block = block
  end

  def call(env)
    @req = Rack::Request.new(env)
    @res = Rack::Response.new(nil, 404)
    @env = env
    @once = false
    catch(:halt){
      try_eval{ not_found{res.write 'Not Found'} }
      return res.finish
    }.call(env)
  end

  def on(u, **params)
    return unless match(u, **params)
    yield *@captures
  end

  def try_eval
    res.status = 200
    instance_eval(&@block)
    raise if [res.body.empty?, res.status == 200].all?
  rescue => @error
    res.status = 404
    yield
  end

  def get;    yield if req.get? end
  def post;   yield if req.post? end
  def put;    yield if req.put? end
  def delete; yield if req.delete? end

  def not_found; run_once{ yield } if res.status == 404 end

  def match(u, **params)
    req.path_info.match(pattern(u))
       .tap { |md|
          @captures = [
            Array(md&.captures), params.merge(H[req.params]).values
         ].flatten.compact
       }
  end

  def pattern(u)
    u.gsub(/:\w+/) { '([^/?#]+)' }
     .then { |comp| %r{^#{comp}/?$} }
  end

  def session
    env['rack.session'] || raise('You need to set up a session middleware. `use Rack::Session`')
  end

  def halt(app)
    throw :halt, app
  end

  private def run_once; return if @once; @once = true; yield end
end
