require 'spec_helper'

Celluloid.logger = ENV['DEBUG'].nil? ? nil : Logger.new($stdout)

describe Observe do
  let!(:observe) { Observe.supervise_as(:observe) }

  # TODO Replace this with factory.
  before do
    [:@exchange1, :@exchange2].each do |var|
      mid     = SecureRandom.random_number(0xffff)
      token   = SecureRandom.random_number(0xff)
      options = { uri_path: [], token: token }

      message  = CoAP::Message.new(:con, :get, mid, '', options)
      exchange = Exchange.new('127.0.0.1', CoAP::PORT, message)

      instance_variable_set(var, exchange)
    end
  end

  let(:dummy1) do
    [@exchange1, {'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/'}, '1']
  end

  let(:dummy2) do
    [@exchange2, {'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/hello'}, '1']
  end

  subject { Celluloid::Actor[:observe] }

  describe '#add' do
    let!(:add) { subject.add(*dummy1) }

    let!(:key) { [dummy1[0].host, dummy1[0].token] }
    let!(:value) { subject[key] }

    it '#to_s' do
      s = '["127.0.0.1", ' + dummy1[0].token.to_s + ', "/", 0]'
      expect(subject.to_s).to eq(s)
    end

    context 'key' do
      it 'presence' do
        expect(subject.size).to eq(1)
        expect(subject.keys.first).to eq(key)
      end
    end

    # [n, exchange, env, etag, timestamp]
    context 'value' do
      let!(:time) { Time.now.to_i }

      it 'type' do
        expect(add).to be_a(Array)
        expect(add.size).to eq(5)
        expect(value).to be_a(Array)
      end

      it 'identity' do
        expect(value[1..3]).to eq(dummy1[0..2])
      end

      it 'observe number' do
        expect(value[0]).to be_a(Integer)
        expect(value[0]).to eq(0)
      end

      it 'timestamp' do
        expect(value[4]).to be_a(Integer)
        expect(value[4]).to be <= time
        expect(value[4]).to be >  time - 2
      end
    end
  end

  describe '#delete' do
    before do
      subject.add(*dummy1)
      subject.add(*dummy2)
      subject.delete(dummy1[0])
    end

    context 'entry' do
      let(:entry) { subject.first.flatten }

      it 'count' do
        expect(subject.size).to eq(1)
      end

      it 'identity' do
        expect(entry.size).to eq(7)

        expect(entry[0]).to eq(dummy2[0].host)
        expect(entry[1]).to eq(dummy2[0].token)

        expect(entry[3..5]).to eq(dummy2)
        expect(entry[6]).to be_a(Integer)
      end
    end
  end

  describe '#include?' do
    before do
      subject.add(*dummy1)
    end

    context 'entry' do
      it 'true' do
        expect(subject.include?(dummy1[0])).to be(true)
      end

      it 'false' do
        expect(subject.include?(dummy2[0])).to be(false)
      end
    end
  end

  describe '#tick' do
    # Couldn't get mocking to work decently.
  end

  describe '#bump' do
    let!(:key) { [dummy1[0].host, dummy1[0].token] }

    let(:n)         { rand(0xff) }
    let(:response)  { dummy1[0].message }

    before { subject.add(*dummy1) }

    it 'shall change entry' do
      subject.send(:bump, key, n, response)

      expect(subject[key][0]).to eq(n)
      expect(subject[key][3]).to eq(response.options[:etag])
      expect(subject[key][4]).to be <= Time.now.to_i
    end
  end

  describe '#handle_update' do
    let(:port) { random_port }

    let!(:server) { supervised_server(:Port => port) }

    context 'error (4.04)' do
      let!(:key) { [dummy1[0].host, dummy1[0].token] }

      before do
        dummy1[0].port = port
        subject.add(*dummy1)
        subject.send(:handle_update, key)
      end

      it 'delete' do
        expect(subject[key]).to eq(nil)
      end
    end

    context 'update (2.05)' do
      let!(:key) { [dummy2[0].host, dummy2[0].token] }

      before do
        dummy2[0].port = port
        subject.add(*dummy2)
        subject.send(:handle_update, key)
      end

      it 'bumped' do
        expect(subject[key][0]).to eq(1)
        expect(subject[key][3]).to eq(dummy2[0].message.options[:etag])
        expect(subject[key][4]).to be <= Time.now.to_i
      end
    end
  end

  describe '#tick' do
    let(:port) { random_port }

    let!(:server) { supervised_server(:Port => port) }

    context 'update (2.05)' do
      let!(:key) { [dummy2[0].host, dummy2[0].token] }

      before do
        dummy2[0].port = port
        subject.add(*dummy2)
        subject.send(:tick, false)
      end

      it 'bumped' do
        expect(subject[key][0]).to eq(1)
        expect(subject[key][3]).to eq(dummy2[0].message.options[:etag])
        expect(subject[key][4]).to be <= Time.now.to_i
      end
    end
  end
end
