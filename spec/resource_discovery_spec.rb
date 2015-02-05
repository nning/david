require 'spec_helper'

describe David::ResourceDiscovery do
  let(:port) { random_port }

  let(:client) do
    CoAP::Client.new(port: port, retransmit: false, recv_timeout: 0.1)
  end

  let!(:server) do
    supervised_server(:Port => port, :Log => debug, :app => Rails.application)
  end

  context 'ordinary request' do
    subject { client.get('/.well-known/core', '::1') }

    context 'response' do
      let(:links) { CoRE::Link.parse_multiple(subject.payload) }

      it 'valid' do
        expect(subject).to be_a(CoAP::Message)
        expect(subject.ver).to eq(1)
        expect(subject.tt).to eq(:ack)
        expect(subject.mcode).to eq([2, 5])
      end

      it 'CoRE::Link' do
        expect(links.size).to eq(9)
        expect(links.map(&:uri).uniq.size).to eq(links.size)

        links.each do |link|
          expect(link.uri).to match(/^\/(cbor|hello|query|seg.*|test|things)/)
        end
      end
    end
  end
  
  context 'filtered request' do
    context 'match' do
      subject { client.get('/.well-known/core?href=new', '::1') }

      context 'response' do
        let(:links) { CoRE::Link.parse_multiple(subject.payload) }

        it 'CoRE::Link' do
          expect(links.size).to eq(1)
          expect(links.first.uri).to eq('/things/new')
        end
      end
    end

    context 'no match' do
      subject { client.get('/.well-known/core?href=foo', '::1') }

      context 'response' do
        let(:links) { CoRE::Link.parse_multiple(subject.payload) }

        it 'empty' do
          expect(links.size).to eq(0)
        end
      end
    end
  end

end
