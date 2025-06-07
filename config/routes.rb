Rails.application.routes.draw do
  resources :projects do
    resources :template, :controller => 'template'
  end
end