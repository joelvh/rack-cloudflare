# frozen_string_literal: true

require 'ipaddr'
require 'net/http'

module Rack
  class Cloudflare
    module IPs
      # See: https://www.cloudflare.com/ips/
      V4_URL = 'https://www.cloudflare.com/ips-v4'
      V6_URL = 'https://www.cloudflare.com/ips-v6'

      class << self
        # List of IPs to reference
        attr_accessor :list

        # Refresh list of IPs in case local copy is outdated
        def refresh!
          self.list = fetch(V4_URL) + fetch(V6_URL)
        end

        def fetch(url)
          parse Net::HTTP.get(URI(url))
        end

        def read(filename)
          parse File.read(filename)
        end

        def parse(string)
          return [] if string.to_s.strip.empty?
          string.split(/[,\s]+/).map { |ip| IPAddr.new(ip.strip) }
        end
      end

      V4 = read("#{__dir__}/../../../data/ips_v4.txt")
      V6 = read("#{__dir__}/../../../data/ips_v6.txt")

      DEFAULTS = V4 + V6

      ### Configure

      self.list = DEFAULTS
    end
  end
end
