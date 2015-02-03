Rails.application.routes.draw do
  resources :things

  get 'hello' => 'tests#benchmark'
  get 'cbor'  => 'tests#cbor'
end
