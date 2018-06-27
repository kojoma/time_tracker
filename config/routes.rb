Rails.application.routes.draw do
  root to: 'home#index'
  devise_for :users
  resources :users, :only => [:index, :show]
  resources :work_hours
  post '/slack/post', to: 'slack/post#callback'
end
