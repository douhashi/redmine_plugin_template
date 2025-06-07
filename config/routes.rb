Rails.application.routes.draw do
  resources :projects do
    resources :skelton, :controller => 'skelton'
  end
end