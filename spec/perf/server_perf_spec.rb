require 'spec_helper'
require 'benchmark'

describe Server, 'performance' do
  before do
    @server = David::Server.supervise_as \
      :david,
      ->(e) { [200, { 'Content-Length' => 0 }, ['']] },
      {:Host => '::1', :Port => CoRE::CoAP::PORT, :Log => 'none'}
  end

  it "should handle GET request in less than #{max1 = 0.0025} seconds" do
    expect(Benchmark.realtime { CoRE::CoAP::Client.new.get('/', '::1') }).to be < max1
  end

  after do
    @server.terminate
  end
end
