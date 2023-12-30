# frozen_string_literal: true

module Rack
  class Cloudflare
    module Middleware
      class RewriteHeaders
        def initialize(app)
          @app = app
        end

        def call(env)
          headers = Headers.new(env)

          unless headers.trusted?
            Cloudflare.warn "[#{self.class.name}] Untrusted Network (REMOTE_ADDR): #{headers.target_headers}"
          end
          Cloudflare.debug "[#{self.class.name}] Target Headers: #{headers.target_headers}"
          Cloudflare.debug "[#{self.class.name}] Rewritten Headers: #{headers.rewritten_target_headers}"

          @app.call(headers.rewrite)
        end
      end
    end
  end
end
