# frozen_string_literal: true

module Rack
  class Cloudflare
    module Middleware
      class AccessControl
        class << self
          attr_accessor :blocked_response, :blocked_message
        end

        self.blocked_message  = 'Forbidden'
        self.blocked_response = lambda do |_env|
          [403, { 'Content-Type' => 'text/plain' }, ["#{blocked_message.strip}\n"]]
        end

        def initialize(app)
          @app = app
        end

        def call(env)
          headers = Headers.new(env)

          if headers.trusted?
            Cloudflare.info "[#{self.class.name}] Trusted Network (REMOTE_ADDR): #{headers.target_headers}"
            @app.call(env)
          else
            Cloudflare.warn "[#{self.class.name}] Untrusted Network (REMOTE_ADDR): #{headers.target_headers}"
            AccessControl.blocked_response.call(env)
          end
        end
      end
    end
  end
end
