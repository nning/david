require 'spec_helper'

include Server::Utility
describe Server::Utility do
  context 'body_to_string' do
    it { expect(body_to_string(['foo', 'bar', 'baz'])).to eq("foo\r\nbar\r\nbaz") }
  end
end
