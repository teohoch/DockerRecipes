Rails.application.routes.draw do
  authenticate :user do
    resources :tournaments, only: [:new, :create, :edit, :update, :destroy] do
      member do
        post :start
        post :end
      end
    end

    resources :matches, only: [:new, :create, :edit, :update, :destroy] do
      member do
        patch :validate
      end
    end

    resources :user_matches, only: [:update, :destroy]
  end

  resources :tournaments, only: [:index, :show]
  resources :matches, only: [:index, :show]
  resources :user_matches, only: [:index]
  resources :inscriptions
  get 'home/index'

  get 'home/show'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
end
