require 'spec_helper'

[
  Interop::MandatoryETSI::Rack,
  Interop::MandatoryETSI::Grape,
].each do |app|
  describe "ETSI Plugstests, Mandatory, #{app.to_s.split('::').last}" do
    let(:port) { random_port }
    let(:mid)  { rand(0xffff) }

    let!(:server) { supervised_server(:Port => port, :MinimalMapping => true, app: app) }

    [:con, :non].each do |tt|
      context tt do
        it 'TD_COAP_CORE_0{1,5}' do
          response = req(:get, '/test', tt: tt)

          expect(response).to be_a(CoAP::Message)
          expect(response.mcode).to eq([2, 5])
          expect(response.mid).to eq(mid)
          expect(response.options[:content_format]).to eq(0)
        end

        it 'TD_COAP_CORE_0{2,6}' do
          response = req(:post, '/test', tt: tt, payload: 'foo',
            content_format: 0)

          expect(response).to be_a(CoAP::Message)
          expect(response.mcode).to eq([2, 1])
          expect(response.mid).to eq(mid)
        end

        it 'TD_COAP_CORE_0{3,7}' do
          response = req(:put, '/test', tt: tt, payload: 'foo',
            content_format: 0)

          expect(response).to be_a(CoAP::Message)
          expect(response.mcode).to eq([2, 4])
          expect(response.mid).to eq(mid)
        end

        it 'TD_COAP_CORE_0{4,8}' do
          response = req(:delete, '/test', tt: tt)

          expect(response).to be_a(CoAP::Message)
          expect(response.mcode).to eq([2, 2])
          expect(response.mid).to eq(mid)
        end
      end
    end

    context 'TD_COAP_CORE_09' do
      pending
    end

    after do
      server.terminate
    end
  end
end
