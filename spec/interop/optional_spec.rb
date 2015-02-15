require 'spec_helper'

[
  ETSI::Optional::Rack,
].each do |app|
  describe "ETSI Plugstests, Optional, #{app.to_s.split('::').last}" do
    let(:port) { random_port }
    let!(:server) { supervised_server(:Port => port, :MinimalMapping => true, app: app) }

    context 'TD_COAP_BLOCK_01' do
      it 'block 0' do
        mid, response = req(:get, '/large', port: port, block2: 0) # 0, false, 16
        block = CoAP::Block.new(response.options[:block2]).decode

        expect(response).to be_a(CoAP::Message)
        expect(response.mcode).to eq([2, 5])
        expect(response.mid).to eq(mid)
        expect(response.payload.size).to eq(16)
        expect(block.num).to eq(0)
        expect(block.more).to eq(true)
        expect(block.size).to eq(16)
      end

      it 'block 1' do
        mid, response = req(:get, '/large', port: port, block2: 16) # 1, false, 16
        block = CoAP::Block.new(response.options[:block2]).decode

        expect(response).to be_a(CoAP::Message)
        expect(response.mcode).to eq([2, 5])
        expect(response.mid).to eq(mid)
        expect(response.payload.size).to eq(16)
        expect(block.num).to eq(1)
        expect(block.more).to eq(true)
        expect(block.size).to eq(16)
      end

      it 'block 64' do
        mid, response = req(:get, '/large', port: port, block2: 1024) # 65, false, 16
        block = CoAP::Block.new(response.options[:block2]).decode

        expect(response).to be_a(CoAP::Message)
        expect(response.mcode).to eq([2, 5])
        expect(response.mid).to eq(mid)
        expect(response.payload.size).to eq(1)
        expect(block.num).to eq(64)
        expect(block.more).to eq(false)
        expect(block.size).to eq(16)
      end

    end

    context 'TD_COAP_BLOCK_02' do
      it 'block 0' do
        mid, response = req(:get, '/large', port: port)
        block = CoAP::Block.new(response.options[:block2]).decode

        expect(response).to be_a(CoAP::Message)
        expect(response.mcode).to eq([2, 5])
        expect(response.mid).to eq(mid)
        expect(response.payload.size).to eq(1024)
        expect(block.num).to eq(0)
        expect(block.more).to eq(true)
        expect(block.size).to eq(1024)
      end

      it 'block 1' do
        mid, response = req(:get, '/large', port: port, block2: 22) # 1, false, 1024
        block = CoAP::Block.new(response.options[:block2]).decode

        expect(response).to be_a(CoAP::Message)
        expect(response.mcode).to eq([2, 5])
        expect(response.mid).to eq(mid)
        expect(response.payload.size).to eq(1)
        expect(block.num).to eq(1)
        expect(block.more).to eq(false)
        expect(block.size).to eq(1024)
      end
    end

    describe 'TD_COAP_OBS_01' do
      before do
        @answers = []

        @t1 = Thread.start do
          CoAP::Client.new.observe \
            '/obs', '::1', port,
            ->(s, m) { @answers << m }
        end

        Timeout.timeout(12) do
          sleep 0.25 while !(@answers.size > 2)
        end
      end

      it 'responses' do
        expect(@answers.size).to be > 2
        @answers.each do |answer|
          obs = answer.options[:observe]
          expect(obs).not_to eq(nil)
          expect(obs).to be >= 0
          expect(obs).to be <= 2
        end
      end

      after do
        @t1.kill
      end
    end

    after do
      server.terminate
    end
  end
end
