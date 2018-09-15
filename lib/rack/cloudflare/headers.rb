# frozen_string_literal: true

require 'json'

module Rack
  class Cloudflare
    class Headers
      # See: https://support.cloudflare.com/hc/en-us/articles/200170986-How-does-Cloudflare-handle-HTTP-Request-headers-
      NAMES = %w[
        HTTP_CF_IPCOUNTRY
        HTTP_CF_CONNECTING_IP
        HTTP_CF_RAY
        HTTP_CF_VISITOR
      ].freeze

      STANDARD = %w[
        HTTP_X_FORWARDED_FOR
        HTTP_X_FORWARDED_PROTO
        REMOTE_ADDR
      ].freeze

      ALL = (NAMES + STANDARD).freeze

      # Create constants for each header
      ALL.map { |h| const_set h, h.to_s.freeze }.freeze

      class << self
        attr_accessor :backup, :original_remote_addr, :original_forwarded_for

        def trusted?(headers)
          Headers.new(headers).trusted?
        end
      end

      def initialize(headers)
        @headers = headers
      end

      # "Cf-Ipcountry: US"
      def ip_country
        @headers.fetch(HTTP_CF_IPCOUNTRY, 'XX')
      end

      # "CF-Connecting-IP: A.B.C.D"
      def connecting_ip
        @connecting_ip ||= IPs.parse(@headers[HTTP_CF_CONNECTING_IP]).first
      end

      # "X-Forwarded-For: A.B.C.D"
      # "X-Forwarded-For: A.B.C.D[,X.X.X.X,Y.Y.Y.Y,]"
      def forwarded_for
        @forwarded_for ||= IPs.parse(@headers[HTTP_X_FORWARDED_FOR])
      end

      # "X-Forwarded-Proto: https"
      def forwarded_proto
        @headers[HTTP_X_FORWARDED_PROTO]
      end

      # "Cf-Ray: 230b030023ae2822-SJC"
      def ray
        @headers[HTTP_CF_RAY]
      end

      # "Cf-Visitor: { \"scheme\":\"https\"}"
      def visitor
        @visitor ||= ::JSON.parse @headers[HTTP_CF_VISITOR] if has?(HTTP_CF_VISITOR)
      end

      def remote_addr
        @remote_addr ||= IPs.parse(@headers[REMOTE_ADDR]).first
      end

      def cloudflare_ip
        @cloudflare_ip ||= IPs.private?(remote_addr) ? forwarded_for.last : remote_addr
      end

      def backup_headers
        return {} unless Headers.backup

        {}.tap do |headers|
          headers[Headers.original_remote_addr]   = @headers[REMOTE_ADDR]
          headers[Headers.original_forwarded_for] = @headers[HTTP_X_FORWARDED_FOR]
        end
      end

      # Headers that relate to Cloudflare
      # See: https://support.cloudflare.com/hc/en-us/articles/200170986-How-does-Cloudflare-handle-HTTP-Request-headers-
      def target_headers
        @headers.select { |k, _| ALL.include? k }
      end

      def rewritten_headers
        # Only rewrites headers if it's a Cloudflare request
        return {} unless trusted?

        {}.tap do |headers|
          headers.merge! backup_headers

          # Overwrite the original remote IP based on
          # Cloudflare's specified original remote IP
          headers[REMOTE_ADDR] = connecting_ip.to_s if connecting_ip

          # Add HTTP_X_FORWARDED_FOR if it wasn't present.
          # Cloudflare will already have modified the header if
          # it was present in the original request.
          # See: https://support.cloudflare.com/hc/en-us/articles/200170986-How-does-Cloudflare-handle-HTTP-Request-headers-
          headers[HTTP_X_FORWARDED_FOR] = "#{connecting_ip}, #{cloudflare_ip}" if forwarded_for.none?
        end
      end

      def rewritten_target_headers
        target_headers.merge(rewritten_headers)
      end

      def rewrite
        @headers.merge(rewritten_headers)
      end

      # Indicates if the headers passed through Cloudflare
      def trusted?
        @trusted ||= IPs.list.any? { |range| range.include? cloudflare_ip }
      end

      def has?(header)
        @headers.key?(header)
      end

      ### Configure

      self.backup                 = true
      self.original_remote_addr   = 'ORIGINAL_REMOTE_ADDR'
      self.original_forwarded_for = 'ORIGINAL_FORWARDED_FOR'
    end
  end
end
