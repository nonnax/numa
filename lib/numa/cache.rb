#!/usr/bin/env ruby
# Id$ nonnax 2022-05-10 10:12:49 +0800
require 'dalli'

class Numa
  module Cache
    def dc(expires_in: 60*60*24 , compress:true)
      options = { expires_in:, compress: }
      @dc ||= Dalli::Client.new('localhost:11211', **options)
    end
    def cache(*key, **opts)
      key=key.join
      unless value=dc.get(key, **opts)
        value=yield
        dc.set(key, value)
      end
      value
    end
  end
  include Cache
end
