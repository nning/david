class TestsController < ActionController::Base
  def benchmark
    render plain: 'Hello World!'
  end

  def cbor
    render plain: params['test'].to_json
  end
end
