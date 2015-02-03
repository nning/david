class TestsController < ActionController::Base
  def benchmark
    render text: 'Hello World!'
  end

  def cbor
    render text: params['test'].to_s
  end
end
