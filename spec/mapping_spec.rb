require 'spec_helper'

include Server::Mapping

describe Server::Mapping do
  context '#etag' do
    context '16 byte hex as string (from Rails for example)' do
      it '0 in first 8 byte' do
        expect(etag({'ETag' => ([0]*32).join})).to eq(0)
        expect(etag({'ETag' => ([0]*16 + [1]*16).join})).to eq(0)
      end

      it '>0 in first 8 byte' do
        expect(etag({'ETag' => ([0]*15 + [1]*17).join})).to eq(1)
        expect(etag({'ETag' => (['f']*16 + [0]*16).join})).to eq(2**64-1)
        expect(etag({'ETag' => '2246fd11002a6bcad940fe5d76a48333'})).to eq(2469939695118347210)
      end
    end
  end
end
