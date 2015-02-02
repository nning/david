require 'spec_helper'

describe AppConfig do
  let(:port) { random_port }

  let!(:server) { supervised_server(:Port => port, :CBOR => true) }

  it { expect(subject).to be_a(Hash) }

  describe '#choose_host' do
    let(:method) do
      ->(*args) { subject.send(:choose_host, *args) }
    end

    it { expect(method.call(nil)).to eq(nil) }
    it { expect(method.call('::')).to eq('::') }
    it { expect(method.call('::1')).to eq('::1') }
    it { expect(method.call('localhost')).to eq('::1') }
  end

  describe '#choose_port' do
    let(:method) do
      ->(*args) { subject.send(:choose_port, *args) }
    end

    it { expect(method.call(nil)).to eq(nil) }
    it { expect(method.call('1')).to be_a(Fixnum) }
    it { expect(method.call('1')).to eq(1) }
  end

  describe '#default_to_true' do
    let(:method) do
      ->(*args) { subject.send(:default_to_true, *args) }
    end

    it { expect(method.call(:block, nil)).to eq(true) }
    it { expect(method.call(:block, true)).to eq(true) }
    it { expect(method.call(:block, 'true')).to eq(true) }

    it { expect(method.call(:block, false)).to eq(false) }
    it { expect(method.call(:block, 'false')).to eq(false) }
  end

  describe '#default_to_false' do
    let(:method) do
      ->(*args) { subject.send(:default_to_false, *args) }
    end

    it { expect(method.call(:cbor, nil)).to eq(false) }
    it { expect(method.call(:cbor, false)).to eq(false) }
    it { expect(method.call(:cbor, 'false')).to eq(false) }

    it { expect(method.call(:cbor, true)).to eq(true) }
    it { expect(method.call(:cbor, 'true')).to eq(true) }
  end
end
