# David

[![Gem Version](https://img.shields.io/gem/v/david.svg)](http://badge.fury.io/rb/david)
[![Dependency Status](https://img.shields.io/gemnasium/nning/david.svg)](https://gemnasium.com/nning/david)
[![Build Status](https://img.shields.io/travis/nning/david.svg)](https://travis-ci.org/nning/david)
[![Coverage Status](https://img.shields.io/coveralls/nning/david.svg)](https://coveralls.io/r/nning/david)
[![Code Climate](https://img.shields.io/codeclimate/github/nning/david.svg)](https://codeclimate.com/github/nning/david)

David is a CoAP server with Rack interface to bring the illustrious family of
Rack compatible web frameworks into the Internet of Things. **Currently, it is
in a development state and probably not ready for use in production.**

## Usage

Just include David in your Gemfile!

    gem 'david'

It will hook into Rack and make itself the default handler, so running `rails
s` starts David. If you want to start WEBrick for example, you can do so by
executing `rails s webrick`.

After the server is started, the Rails application is available at
`coap://[::1]:3000/` by default.

[Copper](https://addons.mozilla.org/de/firefox/addon/copper-270430/) is a CoAP
client for Firefox and can be used for development. The [Ruby coap
gem](https://github.com/nning/coap) is used by David for example for message
parsing and also includes a command line utility (named `coap`) that can also
be used for development.

As [CoAP](https://tools.ietf.org/html/rfc7252) is a protocol for constrained
environments and machine to machine communications, returning HTML from your
controllers will not be of much use. JSON for example is more suitable in that
context. David works well with the default ways to handle JSON responses from
controllers such as `render json:`. You can also utilize [Jbuilder
templates](https://github.com/rails/jbuilder) for easy generation of more
complex JSON structures.

[CBOR](https://tools.ietf.org/html/rfc7049) can be used to compress your JSON.
Automatic transcoding between JSON and CBOR is activated by setting the Rack
environment option `CBOR` or `config.coap.cbor` in your Rails application
config to `true`.

## Tested Rack Frameworks

* [Grape](https://github.com/intridea/grape)
* [Hobbit](https://github.com/patriciomacadden/hobbit)
* [NYNY](https://github.com/alisnic/nyny)
* Plain Rack
* [Sinatra](https://github.com/sinatra/sinatra)
* [Rails](https://github.com/rails/rails)

## Configuration

| Rack key			| Rails key					| Default	| Semantics							|
|---				|---						|---		|---								|
| Block				| coap.block				| true		| Blockwise transfers				|
| CBOR				| coap.cbor					| false		| JSON/CBOR transcoding				|
| DefaultFormat		| coap.default_format		|			| Default Content-Type				|
| Host				|							| ::1 / ::	| Server listening host				|
| Log				|							| info		| Log level (none or debug)			|
| MinimalMapping	|							| false		| Minimal HTTP status codes mapping	|
| Multicast			| coap.multicast			| true		| Multicast support					|
| Observe			| coap.observe				| true		| Observe support					|
|					| coap.only					| true		| Removes (HTTP) middleware			|
| Port				|							| 5683		| Server listening port				|
|					| coap.resource_discovery	| true		| Provision of `.well-known/core`	|

## Discovery

The [CoAP Discovery](https://tools.ietf.org/html/rfc7252#section-7) will be
activated by default. A `.well-known/core` resource automatically returns the
resources you defined in Rails. You can annotate this resources with attributes
like an interface description (`if`) or the content type (`ct`). (See
[RFC6690](https://tools.ietf.org/html/rfc6690) or [the
code](https://github.com/nning/coap/blob/master/lib/core/link.rb#L8) for
further documentation.)

    class ThingsController < ApplicationController
      discoverable \
        default: { if: 'urn:things', ct: 'application/cbor' },
        index:   { if: 'urn:index' }

      def show
        render json: Thing.find(params[:id])
      end

      def index
        render json: Thing.all
      end
	end

## Rack environment

| Key				| Value class	| Semantics |
|---				|---			|--- |
| coap.version		| Integer		| Protocol version of CoAP request |
| coap.multicast	| Boolean		| Marks whether request was received via multicast |
| coap.dtls			| String		| DTLS mode (as defined in [section 9 of RFC7252](https://tools.ietf.org/html/rfc7252#section-9)) |
| coap.dtls.id		| String		| DTLS identity |
| coap.cbor			| Object		| Ruby object deserialized from CBOR |

## Benchmarks

David handles about 11.000 requests per second (tested in MRI 2.2.0 with up to
10.000 concurrent clients on a single core of a Core i7-3520M CPU running Linux
3.18.5).

## Copyright

The code is published under the GPLv3 license (see the LICENSE file).

### Authors

* [henning mueller](https://nning.io)
