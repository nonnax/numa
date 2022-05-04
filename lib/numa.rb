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
      return try_eval{ not_found{ res.write 'Not Found'} }
    }.call(env)
  end

  def on(u, **params)
    return unless @matched=match(u, **params)
    yield *@captures
  end

  def try_eval
    res.status = 200
    instance_eval(&@block)
    res.status=404 if [res.body.empty?, res.status == 200].all?
    yield if res.status==404
    res.finish
  rescue => @error
    p @error
  end

  def get;    yield if req.get? end
  def head;   yield if req.head? end
  def post;   yield if req.post? end
  def put;    yield if req.put? end
  def delete; yield if req.delete? end

  def not_found
    if res.status == 404
      defined?(@default) ? @default.call : yield       
    end
  end

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

  def default(&block)
    @default=block
  end
end
