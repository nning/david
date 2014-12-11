require 'spec_helper'
require 'benchmark'

describe Server do
  let(:port) { random_port }
  let(:client) do
    CoAP::Client.new(port: port, retransmit: false, recv_timeout: 0.1)
  end

  let!(:server) { supervised_server(:Port => port, :Log => debug) }

  context 'ordinary request' do
    subject { client.get('/hello', '::1') }

    it 'should be plausible' do
      expect(subject).to be_a(CoAP::Message)
      expect(subject.ver).to eq(1)
      expect(subject.tt).to eq(:ack)
      expect(subject.mcode).to eq([2, 5])
      expect(subject.payload).to eq('Hello World!')
    end
  end

  context 'missing resource' do
    subject { client.get('/404', '::1') }

    it 'should be 4.04' do
      expect(subject).to be_a(CoAP::Message)
      expect(subject.ver).to eq(1)
      expect(subject.tt).to eq(:ack)
      expect(subject.mcode).to eq([4, 4])
      expect(subject.payload).to eq('')
    end
  end

  context 'unsupported method' do
    subject { client.delete('/hello', '::1') }

    it 'should be 4.05' do
      expect(subject).to be_a(CoAP::Message)
      expect(subject.ver).to eq(1)
      expect(subject.tt).to eq(:ack)
      expect(subject.mcode).to eq([4, 5])
      expect(subject.payload).to eq('')
    end
  end

  # See https://tools.ietf.org/html/rfc7252#section-12.8
  context 'multicast' do
    let(:client) do
      CoAP::Client.new(port: port, retransmit: false, recv_timeout: 0.1,
        tt: :non)
    end

    # -A INPUT -m pkttype --pkt-type multicast -d ff02::fd -j ACCEPT
    context 'ipv6', multicast: :ipv6 do
      ['ff02::1', 'ff02::fd', 'ff05::fd'].each do |address|
        context address do
          subject { client.get('/hello', address) }

          it 'should be 2.05' do
            expect(subject).to be_a(CoAP::Message)
            expect(subject.ver).to eq(1)
            expect(subject.tt).to eq(:non)
            expect(subject.mcode).to eq([2, 5])
            expect(subject.payload).to eq('Hello World!')
          end
        end
      end

      context '4.04' do
        subject { client.get('/404', 'ff02::fd') }

        it 'should timeout' do
          expect { subject }.to raise_error(Timeout::Error)
        end
      end

      context 'con' do
        let(:client) do
          CoAP::Client.new(port: port, retransmit: false, recv_timeout: 0.1,
            tt: :con)
        end

        subject { client.get('/hello', 'ff02::fd') }

        it 'should timeout' do
          expect { subject }.to raise_error(Timeout::Error)
        end
      end
    end

    # -A INPUT -m pkttype --pkt-type multicast -d 224.0.1.187 -j ACCEPT
    context 'ipv4', multicast: :ipv4 do
      let!(:server) do
        supervised_server(:Host => '0.0.0.0', :Port => port, :Log => debug)
      end

      ['224.0.0.1', '224.0.1.187'].each do |address|
        context address do
          subject { client.get('/hello', address) }

          it 'should be 2.05' do
            expect(subject).to be_a(CoAP::Message)
            expect(subject.ver).to eq(1)
            expect(subject.tt).to eq(:non)
            expect(subject.mcode).to eq([2, 5])
            expect(subject.payload).to eq('Hello World!')
          end
        end
      end

      context '4.04' do
        subject { client.get('/404', '224.0.1.187') }

        it 'should timeout' do
          expect { subject }.to raise_error(Timeout::Error)
        end
      end

      context 'con' do
        let(:client) do
          CoAP::Client.new(port: port, retransmit: false, recv_timeout: 0.1,
            tt: :con)
        end

        subject { client.get('/hello', '224.0.1.187') }

        it 'should timeout' do
          expect { subject }.to raise_error(Timeout::Error)
        end
      end
    end
  end

  context 'block' do
    context 'block2.more set' do
      subject { client.get('/', '::1', nil, nil, block2: 14) }

      it 'should be an error' do
        expect(subject).to be_a(CoAP::Message)
        expect(subject.ver).to eq(1)
        expect(subject.tt).to eq(:ack)
        expect(subject.mcode).to eq([4, 5])
        expect(subject.payload).to eq('')
      end
    end

    context 'non existent' do
      let(:client) do
        CoAP::Client.new \
          port: port,
          retransmit: false,
          recv_timeout: 0.1
      end

      subject { client.get('/hello', '::1', nil, nil, block2: 16) }

      it 'should be an error' do
        expect { subject }.to raise_error(Timeout::Error)
      end
    end

    context 'transfer' do
      subject do
        [0, 16].map do |x|
          client.get('/block', '::1', nil, nil, block2: x)
        end
      end

      it { expect(subject[0].mcode).to eq([2, 5]) }
      it { expect(subject[0].payload.bytesize).to eq(16) }

      it { expect(subject[1].mcode).to eq([2, 5]) }
      it { expect(subject[1].payload.bytesize).to eq(1) }
    end
  end

  context 'accept' do
    context 'unset' do
      subject { client.get('/hello', '::1') }

      it 'should return resource' do
        expect(subject).to be_a(CoAP::Message)
        expect(subject.ver).to eq(1)
        expect(subject.tt).to eq(:ack)
        expect(subject.mcode).to eq([2, 5])
        expect(subject.payload).to eq('Hello World!')
        expect(subject.options[:content_format]).to eq(0)
      end
    end

    context 'default' do
      subject { client.get('/echo/accept', '::1') }

      it 'should return default' do
        expect(subject).to be_a(CoAP::Message)
        expect(subject.ver).to eq(1)
        expect(subject.tt).to eq(:ack)
        expect(subject.mcode).to eq([2, 5])
        expect(subject.payload).to eq('')
        expect(subject.options[:content_format]).to eq(50)
      end
    end

    context 'right' do
      subject { client.get('/echo/accept', '::1', nil, nil, accept: 40) }

      it 'should echo' do
        expect(subject).to be_a(CoAP::Message)
        expect(subject.ver).to eq(1)
        expect(subject.tt).to eq(:ack)
        expect(subject.mcode).to eq([2, 5])
        expect(subject.payload).to eq('')
        expect(subject.options[:content_format]).to eq(40)
      end
    end

    context 'wrong' do
      subject { client.get('/hello', '::1', nil, nil, accept: 40) }

      it 'should be an error' do
        expect(subject).to be_a(CoAP::Message)
        expect(subject.ver).to eq(1)
        expect(subject.tt).to eq(:ack)
        expect(subject.mcode).to eq([4, 6])
        expect(subject.payload).to eq('')
      end
    end
  end

  context 'deduplication' do
    context 'duplicates' do
      let(:a) do
        ([0]*3).map { client.get('/value', '::1', nil, nil, mid: 1, token: 1) }
      end

      it 'matching mid' do
        expect(a[0].mid).to eq(a[1].mid)
        expect(a[1].mid).to eq(a[2].mid)
      end

      it 'matching token' do
        expect(a[0].options[:token]).to eq(a[1].options[:token])
        expect(a[1].options[:token]).to eq(a[2].options[:token])
      end

      it 'matching payload' do
        expect(a[0].payload).to eq(a[1].payload)
        expect(a[1].payload).to eq(a[2].payload)
      end
    end

    context 'different' do
      let(:a) do
        ([0]*3).map { client.get('/value', '::1') }
      end

      it 'matching mid' do
        expect(a[0].mid).not_to eq(a[1].mid)
        expect(a[1].mid).not_to eq(a[2].mid)
      end

      it 'matching token' do
        expect(a[0].options[:token]).not_to eq(a[1].options[:token])
        expect(a[1].options[:token]).not_to eq(a[2].options[:token])
      end

      it 'matching payload' do
        expect(a[0].payload).not_to eq(a[1].payload)
        expect(a[1].payload).not_to eq(a[2].payload)
      end
    end
  end

  after do
    server.terminate
  end
end
