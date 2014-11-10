require 'spec_helper'

describe Rack::Handler do
  describe '.default' do
    context 'default' do
      it { expect(Rack::Handler.default).to eq(Rack::Handler::David) }
    end

    context 'env' do
      it 'RACK_HANDLER' do
        ENV['RACK_HANDLER'] = 'webrick'
        expect(Rack::Handler.default).to eq(Rack::Handler::WEBrick)
      end
    end
  end
end
