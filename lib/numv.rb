# frozen_string_literal: true

require 'erb'
class Numa
  def self.settings
    @settings ||= Hash.new { |h, k| h[k] = {} }
  end

  settings[:views]  = :views
  settings[:layout] = :layout

  module View
    PATH = Hash.new { |h, k| h[k] = File.expand_path("#{Numa.settings[:views]}/#{k}.erb", Dir.pwd) }
    CACHE = Thread.current[:_view_cache] = Hash.new { |h, k| h[k] = String(IO.read(k)) }

    def erb(doc, **locals)
      res.headers[Rack::CONTENT_TYPE] ||= 'text/html; charset=utf8;'
      s = prepare(doc, **locals){|doc, layout|
        render(layout, **locals){ render(doc, **locals) }
      }
      res.write s
    end

    def render(text, **opts)
      new_b = binding.dup.instance_eval do
        tap { opts.each { |k, v| local_variable_set k, v } }
      end
      ERB.new(text, trim_mode: '%').result(new_b)
    end

    def prepare(doc, **locals)
      ldir =   locals.fetch(:layout, Numa.settings[:layout])
      doc  =   CACHE[PATH[doc]]  if doc.is_a?(Symbol)
      layout = CACHE[PATH[ldir]] rescue '<%=yield%>'
      yield *[String(doc), layout]
    end
  end
  include View
end
