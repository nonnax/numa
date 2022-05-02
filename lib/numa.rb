#!/usr/bin/env ruby
# Id$ nonnax 2022-04-30 11:09:50 +0800
# notta unified mapper, boom!
require_relative 'numv'

class Numa
  attr :req, :res, :env

  def initialize(&block)
    @block=block
  end

  def call(env)
    @req=Rack::Request.new(env)
    @res=Rack::Response.new(nil, 404)
    @env=env
    @once=false
    instance_eval(&@block)
    not_found{ res.write 'Not Found'}
    res.finish
  end

  def on(u, **params)
    return unless match(u, **params)
    res.status=200
    yield *@captures
    res.status=404 if [res.body.empty?, res.status==200].all?
  end

  def get;    yield if req.get? end
  def post;   yield if req.post? end
  def put;    yield if req.put? end
  def delete; yield if req.delete? end

  def not_found; run_once{yield} if res.status==404 end

  def match(u, **params)
    req.path_info.match(pattern(u))
       .tap { |md|
        cap = Array(md&.captures)
        @captures = [cap, params.merge(req.params.transform_keys(&:to_sym)).values].flatten.compact
       }
  end

  def pattern(u)
    u.gsub(/:\w+/) { '([^/?#]+)' }
     .then { |comp| %r{^#{comp}/?$} }
  end

  def session
    env['rack.session'] || raise('You need to set up a session middleware. `use Rack::Session`')
  end

  private def run_once; return if @once; @once=true; yield end
end
