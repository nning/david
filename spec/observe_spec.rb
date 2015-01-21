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

  let(:dummy1) { [@exchange1, {'PATH_INFO' => '/'}, '1'] }
  let(:dummy2) { [@exchange2, {'PATH_INFO' => '/'}, '1'] }

  subject { Celluloid::Actor[:observe] }

  describe '#add' do
    let!(:add) { subject.add(*dummy1) }

    let!(:key) { [dummy1[0].host, dummy1[0].token] }
    let!(:value) { subject[key] }

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
end
