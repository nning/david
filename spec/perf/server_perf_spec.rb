require 'spec_helper'
require 'benchmark'

describe Server, 'performance' do
  subject { CoAP::Client.new(max_retransmit: 0, recv_timeout: 1) }

  before do
    @server = David::Server.supervise_as \
      :david,
      ->(e) { [200, { 'Content-Length' => 0 }, ['']] },
      {:Host => '::1', :Port => CoAP::PORT, :Log => 'none'}
  end

  it "should handle GET request in less than #{max1 = 0.0025} seconds" do
    expect(Benchmark.realtime { subject.get('/', '::1') }).to be < max1
  end

  after do
    @server.terminate
  end
end
