#\ -o ::1 -p 5683 -O Block=false -O Multicast=false -O Observe=false -O Log=none -E none

require 'bundler/setup'
Bundler.setup

require 'david'
require 'grape'

class Dummy < Grape::API
  content_type :txt, 'text/plain'
  default_format :txt

  get :hello do
    'Hello World!'
  end
end

run Dummy.new
