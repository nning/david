module David::ETSI::Mandatory
  class Roda < ::Roda
    plugin :all_verbs
    plugin :default_headers, 'Content-Type' => 'text/plain'

    route do |r|
      r.get 'test' do
        response.status = 2.05
      end
      
      r.post :test do
        response.status = 2.01
      end
      
      r.put :test do
        response.status = 2.04
      end
      
      r.delete :test do
        response.status = 2.02
      end

      r.on 'seg1' do
        r.on 'seg2' do
          r.get 'seg3' do
            response.status = 2.05
          end
        end
      end

      r.get 'query' do
        response.status = 2.05
      end
    end
  end
end
