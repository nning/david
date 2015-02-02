Rails.application.routes.draw do
  resources :things

  get  'hello' => 'tests#benchmark'
  post 'cbor'  => 'tests#cbor'
end
