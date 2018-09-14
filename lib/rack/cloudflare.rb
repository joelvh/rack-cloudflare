# frozen_string_literal: true

require_relative 'cloudflare/version'
require_relative 'cloudflare/countries'
require_relative 'cloudflare/ips'
require_relative 'cloudflare/headers'

require_relative 'cloudflare/middleware/access_control'
require_relative 'cloudflare/middleware/rewrite_headers'

module Rack
  class Cloudflare
    class << self
      attr_accessor :logger

      %i[info debug warn error].each do |m|
        define_method(m) { |*args| logger&.__send__(m, *args) }
      end
    end
  end
end
