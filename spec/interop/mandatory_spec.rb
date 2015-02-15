require 'spec_helper'

[
  ETSI::Mandatory::Grape,
  ETSI::Mandatory::Hobbit,
  ETSI::Mandatory::NYNY,
  ETSI::Mandatory::Rack,
  ETSI::Mandatory::Sinatra,
  Rails.application
].each do |app|
  describe "ETSI Plugstests, Mandatory, #{app.to_s.split('::').last}" do
    let(:port) { random_port }
    let!(:server) { supervised_server(:Port => port, :MinimalMapping => true, app: app) }

    [:con, :non].each do |tt|
      context tt do
        it 'TD_COAP_CORE_0{1,5}' do
          mid, response = req(:get, '/test', tt: tt)

          expect(response).to be_a(CoAP::Message)
          expect(response.mcode).to eq([2, 5])
          expect(response.mid).to eq(mid)
          expect(response.options[:content_format]).to eq(0)
        end

        it 'TD_COAP_CORE_0{2,6}' do
          mid, response = req(:post, '/test', tt: tt, payload: 'foo',
            content_format: 0)

          expect(response).to be_a(CoAP::Message)
          expect(response.mcode).to eq([2, 1])
          expect(response.mid).to eq(mid)
        end

        it 'TD_COAP_CORE_0{3,7}' do
          mid, response = req(:put, '/test', tt: tt, payload: 'foo',
            content_format: 0)

          expect(response).to be_a(CoAP::Message)
          expect(response.mcode).to eq([2, 4])
          expect(response.mid).to eq(mid)
        end

        it 'TD_COAP_CORE_0{4,8}' do
          mid, response = req(:delete, '/test', tt: tt)

          expect(response).to be_a(CoAP::Message)
          expect(response.mcode).to eq([2, 2])
          expect(response.mid).to eq(mid)
        end
      end
    end

    it 'TD_COAP_CORE_10' do
      token = rand(0xffffffff)
      mid, response = req(:get, '/test', token: token)

      expect(response).to be_a(CoAP::Message)
      expect(response.mcode).to eq([2, 5])
      expect(response.mid).to eq(mid)
      expect(response.options[:content_format]).to eq(0)
      expect(response.options[:token]).to eq(token)
    end

    it 'TD_COAP_CORE_11' do
      mid, response = req(:get, '/test')

      expect(response).to be_a(CoAP::Message)
      expect(response.mcode).to eq([2, 5])
      expect(response.mid).to eq(mid)
      expect(response.options[:content_format]).to eq(0)
      expect(response.options[:token]).to eq(0)
    end

    it 'TD_COAP_CORE_12' do
      mid, response = req(:get, '/seg1/seg2/seg3')

      expect(response).to be_a(CoAP::Message)
      expect(response.mcode).to eq([2, 5])
      expect(response.mid).to eq(mid)
      expect(response.options[:content_format]).to eq(0)
    end

    it 'TD_COAP_CORE_13' do
      mid, response = req(:get, '/query', uri_query: ['foo=1', 'bar=2'])

      expect(response).to be_a(CoAP::Message)
      expect(response.mcode).to eq([2, 5])
      expect(response.mid).to eq(mid)
      expect(response.options[:content_format]).to eq(0)
    end

    after do
      server.terminate
    end
  end
end
