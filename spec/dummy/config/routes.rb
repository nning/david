Rails.application.routes.draw do
  # For testing resource discovery middleware
  resources :things

  # Requests per second benchmark
  get 'hello' => 'tests#benchmark'

  # CBOR transcoding tests
  get 'cbor'  => 'tests#cbor'

  # ETSI Plugtests
  get     'test'            => 'etsis#show'
  post    'test'            => 'etsis#update'
  put     'test'            => 'etsis#create'
  delete  'test'            => 'etsis#destroy'
  get     'seg1/seg2/seg3'  => 'etsis#seg'
  get     'query'           => 'etsis#query'
end
