require 'spec_helper'
require 'benchmark'

describe Server, 'performance' do
  let(:port) { random_port }

  subject! do
    supervised_server \
      :Port => port, :Block => false, :Multicast => false,
      :app => ->(e) { [200, { 'Content-Length' => 0 }, ['']] }
  end

  let(:client) do
    CoAP::Client.new(port: port, retransmit: false, recv_timeout: 0.05)
  end

  # Stolen from thin.
  it "should handle GET request in less than #{max1 = 0.0045} seconds" do
    expect(Benchmark.realtime { client.get('/', '::1') }).to be < max1
  end

  after do
    subject.terminate
  end
end
