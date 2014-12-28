require 'spec_helper'

include Server::Mapping

describe Server::Mapping do
  context '#etag_to_coap' do
    context '16 byte hex as string (from Rails for example)' do
      it '0 in first 8 byte' do
        expect(etag_to_coap({'ETag' => ([0]*32).join})).to eq(0)
        expect(etag_to_coap({'ETag' => ([0]*16 + [1]*16).join})).to eq(0)
      end

      it '>0 in first 8 byte' do
        expect(etag_to_coap({'ETag' => ([0]*15 + [1]*17).join})).to eq(1)
        expect(etag_to_coap({'ETag' => (['f']*16 + [0]*16).join})).to eq(2**64-1)
        expect(etag_to_coap({'ETag' => '2246fd11002a6bcad940fe5d76a48333'})).to eq(2469939695118347210)
        expect(etag_to_coap({'ETag' => 'W/"2246fd11002a6bcad940fe5d76a48333"'})).to eq(2469939695118347210)
      end
    end
  end

  context 'location_to_coap' do
    it { expect(location_to_coap({})).to eq(nil) }
    it { expect(location_to_coap({'Location' => nil})).to eq(nil) }
    it { expect(location_to_coap({'Location' => '/rd'})).to eq(%w[rd]) }
    it { expect(location_to_coap({'Location' => '/rd/1'})).to eq(%w[rd 1]) }
    it { expect(location_to_coap({'Location' => '/'})).to eq(nil) }
    it { expect(location_to_coap({'Location' => '///'})).to eq(nil) }
  end
end
