# frozen_string_literal: true

require 'ipaddr'
require 'open-uri'

module Rack
  class Cloudflare
    module IPs
      # See: https://www.cloudflare.com/ips/
      V4_URL = 'https://www.cloudflare.com/ips-v4'
      V6_URL = 'https://www.cloudflare.com/ips-v6'

      class << self
        # List of IPs to reference
        attr_accessor :list

        def private?(ip)
          PRIVATE.any? { |range| range.include? ip }
        end

        # Update list of IPs in-memory in case local copy is outdated
        def update!
          self.list = fetch(V4_URL) + fetch(V6_URL)
        end

        def fetch(url)
          Cloudflare.info "[#{name}] Updating Cloudflare IP list: #{url.inspect}"
          parse URI(url).read
        rescue OpenURI::HTTPError => ex
          Cloudflare.error "[#{name}] #{ex.class.name} fetching #{url.inspect}: #{ex.message}"
          []
        end

        def read(filename)
          parse ::File.read(filename)
        end

        def parse(string)
          return [] if string.to_s.strip.empty?

          string.strip.split(/[,\s]+/).map { |ip| ::IPAddr.new(ip.strip) }
        end
      end

      V4       = read("#{__dir__}/../../../data/ips_v4.txt")
      V6       = read("#{__dir__}/../../../data/ips_v6.txt")
      PRIVATE  = parse('10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16')
      DEFAULTS = V4 + V6

      ### Configure

      self.list = DEFAULTS
    end
  end
end
