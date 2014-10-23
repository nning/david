require 'spec_helper'
require 'benchmark'

describe Server do
  let(:port) { random_port }
  let(:client) { CoAP::Client.new(port: port) }

  subject! { supervised_server(:Port => port) }

  context 'response to ordinary request' do
    let(:response) { client.get('/hello', '::1') }

    it 'should be plausible' do
      expect(response).to be_a(CoAP::Message)
      expect(response.ver).to eq(1)
      expect(response.tt).to eq(:ack)
      expect(response.mcode).to eq([2, 5])
      expect(response.payload).to eq('Hello World!')
    end
  end

  context 'response to request for missing resource' do
    let(:response) { client.get('/404', '::1') }

    it 'should be 404' do
      expect(response).to be_a(CoAP::Message)
      expect(response.ver).to eq(1)
      expect(response.tt).to eq(:ack)
      expect(response.mcode).to eq([4, 4])
      expect(response.payload).to eq('')
    end
  end

  context 'response to request with unsupported method' do
    let(:response) { client.delete('/hello', '::1') }

    it 'should be 405' do
      expect(response).to be_a(CoAP::Message)
      expect(response.ver).to eq(1)
      expect(response.tt).to eq(:ack)
      expect(response.mcode).to eq([4, 5])
      expect(response.payload).to eq('')
    end
  end

  context 'response to request with block2.more set' do
    let(:response) { client.get('/', '::1', nil, nil, block2: 14) }

    it 'should be an error' do
      expect(response).to be_a(CoAP::Message)
      expect(response.ver).to eq(1)
      expect(response.tt).to eq(:ack)
      expect(response.mcode).to eq([4, 5])
      expect(response.payload).to eq('')
    end
  end

  after do
    subject.terminate
  end
end
