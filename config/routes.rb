Rails.application.routes.draw do
  root 'static_pages#home'
  get '/about', to: 'static_pages#about'
  devise_for :users, controllers: {
    sessions:       'users/sessions',
    registrations:  'users/registrations'
  }
  devise_for :fps, controllers: {
    sessions:       'fps/sessions',
    registrations:  'fps/registrations'
  }
  get 'slots', to: 'slots#index'
  post 'slots/create', to: 'slots#create'
  post 'slots/update', to: 'slots#update'
  get 'slots/render_user_recent', to: 'slots#render_user_recent'
end
