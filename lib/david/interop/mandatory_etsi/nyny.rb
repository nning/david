module David::Interop::MandatoryETSI
  class NYNY < ::NYNY::App
    before { headers['Content-Type'] = 'text/plain' }

    get '/test' do
      # NYNY calls #to_i on status and resets headers on 205.
      status 200
      nil
    end

    post '/test' do
      status 201
      nil
    end

    put '/test' do
      status 204
      nil
    end

    delete '/test' do
      status 202
      nil
    end

    get '/seg1/seg2/seg3' do
      status 200
      nil
    end

    get '/query' do
      status 200
      nil
    end
  end
end
