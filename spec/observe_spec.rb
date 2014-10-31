require 'spec_helper'

Celluloid.logger = ENV['DEBUG'].nil? ? nil : Logger.new($stdout)

describe Observe do
  let!(:observe) { Observe.supervise_as(:observe) }
  let(:dummy1) { ['127.0.0.1', 1, {'PATH_INFO' => '/'}, '1'] }
  let(:dummy2) { ['127.0.0.1', 2, {'PATH_INFO' => '/'}, '1'] }

  subject { Celluloid::Actor[:observe] }

  describe '#add' do
    let!(:add) { subject.add(*dummy1) }

    let!(:key) { dummy1[0..1] }
    let!(:value) { subject[key] }

    context 'key' do
      it 'presence' do
        expect(subject.size).to eq(1)
        expect(subject.keys.first).to eq(key)
      end
    end

    context 'value' do
      let!(:time) { Time.now.to_i }

      it 'type' do
        expect(add).to be_a(Array)
        expect(add.size).to eq(3)
      end

      it 'identity' do
        expect(value).to be_a(Array)
        expect(value[0]).to eq(dummy1[2])
        expect(value[1]).to eq(dummy1[3])
      end

      it 'timestamp' do
        expect(value[2]).to be_a(Integer)
        expect(value[2]).to be <= time
        expect(value[2]).to be >  time - 2
      end
    end
  end

  describe '#delete' do
    before do
      subject.add(*dummy1)
      subject.add(*dummy2)
      subject.delete(*dummy1[0..1])
    end

    context 'entry' do
      let(:entry) { subject.first.flatten }

      it 'count' do
        expect(subject.size).to eq(1)
      end

      it 'identity' do
        expect(entry.size).to eq(dummy2.size + 1)
        expect(entry[0..3]).to eq(dummy2)
        expect(entry[4]).to be_a(Integer)
      end
    end
  end

  describe '#include?' do
    before do
      subject.add(*dummy1)
    end

    context 'entry' do
      let(:key1) { dummy1[0..1] }
      let(:key2) { dummy2[0..1] }

      it 'true' do
        expect(subject.include?(*key1)).to be(true)
      end

      it 'false' do
        expect(subject.include?(*key2)).to be(false)
      end
    end
  end

  describe '#tick' do
    # Couldn't get mocking to work decently.
  end
end
