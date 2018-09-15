# Rack::Cloudflare

Deal with Cloudflare features in your Ruby app using Rack middleware. Also provides a Ruby toolkit to deal with Cloudflare in other contexts if you'd like.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-cloudflare'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-cloudflare

## Usage

### Whitelist Cloudflare IP addresses

You can block access to non-Cloudflare networks using `Rack::Cloudflare::Middleware::AccessControl`.

```ruby
require 'rack/cloudflare'

# In config.ru (recommended for Rails as well to preempt application loading)
use Rack::Cloudflare::Middleware::AccessControl

# In Rails middleware: config/application.rb
config.middleware.unshift Rack::Cloudflare::Middleware::AccessControl

# Configure custom blocked message (defaults to "Forbidden")
Rack::Cloudflare::Middleware::AccessControl.blocked_message = "You don't belong here..."

# Fully customize the Rack response (such as making it a redirect)
Rack::Cloudflare::Middleware::AccessControl.blocked_response = lambda do |_env|
    [301, { 'Location' => 'https://somewhere.else.xyz' }, ["Redirecting...\n"]]
end
```

Alternatively, using [`Rack::Attack`](https://github.com/kickstarter/rack-attack) you can easily add a "safelist" rule.

```ruby
Rack::Attack.safelist('Only allow requests through the Cloudflare network') do |request|
    Rack::Cloudflare::Headers.trusted?(request.env)
end
```

Utilizing the `trusted?` helper method, you can implement a similar check using other middleware.

See _Toolkits: Detect Cloudflare Requests_ for alternative uses.

### Rewrite Cloudflare Remote/Client IP address

You can set `REMOTE_ADDR` to the correct remote IP using `Rack::Cloudflare::Middleware::RewriteHeaders`.

```ruby
require 'rack/cloudflare'

# In config.ru
use Rack::Cloudflare::Middleware::RewriteHeaders

# In Rails config/application.rb
config.middleware.use Rack::Cloudflare::Middleware::RewriteHeaders
```

You can customize whether rewritten headers should be backed up and what names to use.

```ruby
# Toggle header backups (default: true)
Rack::Cloudflare::Headers.backup = false

# Rename backed up headers (defaults: "ORIGINAL_REMOTE_ADDR", "ORIGINAL_FORWARDED_FOR")
Rack::Cloudflare::Headers.original_remote_addr   = 'BACKUP_REMOTE_ADDR'
Rack::Cloudflare::Headers.original_forwarded_for = 'BACKUP_FORWARDED_FOR'
```

See _Toolkits: Rewrite Headers_ for alternative uses.

### Logging

You can enable logging to see what requests are blocked or headers are rewritten.

```ruby
Rack::Cloudflare.logger = Logger.new(STDOUT)
```

Log levels used are INFO, DEBUG and WARN.

## Toolkits

### Detect Cloudflare Requests

You can very easily check your HTTP headers to see if the request came from a Cloudflare network.

```ruby
# Your headers are in a `Hash` format
# e.g. { 'REMOTE_ADDR' => '0.0.0.0', ... }
# Verifies the remote address
Rack::Cloudflare::Headers.trusted?(headers)
```

Note that we can only trust the `REMOTE_ADDR` header to verify a request came from Cloudflare.
The `HTTP_X_FORWARDED_FOR` header can be modified and therefore not trusted.

Make sure your web server does not modify `REMOTE_ADDR` because it could cause security holes.
Read this article, for example: [Anatomy of an Attack: How I Hacked StackOverflow](https://blog.ircmaxell.com/2012/11/anatomy-of-attack-how-i-hacked.html)

### Rewrite Headers

We can easily rewrite `REMOTE_ADDR` and add `HTTP_X_FORWARDED_FOR` based on verifying the request comes from a Cloudflare network.

```ruby
# Get a list of headers relevant to Cloudflare (unmodified)
headers = Rack::Cloudflare::Headers.new(headers).target_headers

# Get a list of headers that will be rewritten (modified)
headers = Rack::Cloudflare::Headers.new(headers).rewritten_headers

# Get a list of headers relevant to Cloudflare with rewritten values
headers = Rack::Cloudflare::Headers.new(headers).rewritten_target_headers

# Update original headers with rewritten ones
headers = Rack::Cloudflare::Headers.new(headers).rewrite
```

### Up-to-date Cloudflare IP addresses

Cloudflare provides a [list of IP addresses](https://www.cloudflare.com/ips/) that are important to keep up-to-date.

A copy of the IPs are kept in [/data](./data/). The list is converted to a `IPAddr` list and is accessible as:

```ruby
# Configurable list of IPs
# Defaults to Rack::Cloudflare::IPs::DEFAULTS
Rack::Cloudflare::IPs.list
```

The list can be updated to Cloudflare's latest published IP lists in-memory:

```ruby
# Fetches Rack::Cloudflare::IPs::V4_URL and Rack::Cloudflare::IPs::V6_URL
Rack::Cloudflare::IPs.update!

# Updates cached list in-memory
Rack::Cloudflare::IPs.list
```

## Credits

Inspired by:

* https://github.com/tatey/rack-cloudflare
* https://github.com/rikas/cloudflare_localizable

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joelvh/rack-cloudflare.
