module David::Interop::MandatoryETSI
  class Hobbit < ::Hobbit::Base
    get '/test' do
      response.status = 2.05
      response['Content-Type'] = 'text/plain'
    end

    post '/test' do
      response.status = 2.01
    end

    put '/test' do
      response.status = 2.04
    end

    delete '/test' do
      response.status = 2.02
    end

    get '/seg1/seg2/seg3' do
      response.status = 2.05
      response['Content-Type'] = 'text/plain'
    end

    get '/query' do
      response.status = 2.05
      response['Content-Type'] = 'text/plain'
    end
  end
end
