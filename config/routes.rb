Rails.application.routes.draw do
  root 'static_pages#home'
  get '/about', to: 'static_pages#about'
  devise_for :users, controllers: {
    sessions:       'users/sessions',
    registrations:  'users/registrations'
  }
end
