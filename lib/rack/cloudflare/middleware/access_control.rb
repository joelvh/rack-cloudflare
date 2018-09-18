# frozen_string_literal: true

module Rack
  class Cloudflare
    module Middleware
      class AccessControl
        PRESETS = {
          forbidden: {
            message: 'Forbidden',
            response: lambda do |_env|
              [403, { 'Content-Type' => 'text/plain' }, ["#{AccessControl.message.strip}\n"]]
            end
          },
          not_found: {
            message: 'Not Found',
            response: lambda do |_env|
              [404, { 'Content-Type' => 'text/plain' }, ["#{AccessControl.message.strip}\n"]]
            end
          }
        }.freeze

        class << self
          attr_accessor :response, :message

          def as(preset, message: nil)
            self.message,
            self.response = PRESETS.fetch(preset).values_at :message, :response

            self.message = message unless message.nil?

            self
          end
        end

        # Default setup
        as :forbidden

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
            AccessControl.response.call(env)
          end
        end
      end
    end
  end
end
