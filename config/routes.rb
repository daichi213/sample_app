Rails.application.routes.draw do
  # 以下に定義したurlのプレフィックスではasオプションで定義した「名称」_pathで使用できる。
  # _pathではroot_path以下しかurlが表示されないが、_urlを使用すると絶対パスで表示される。
  root 'static_pages#home'

  get 'static_pages/help' , to: "static_pages#help" , as: "help"

  get 'static_pages/about' , to: "static_pages#about" , as: "about"

  get 'static_pages/contact' , to: "static_pages#contact" , as: "contact"

  get '/signup' , to: "users#new"

  post '/signup', to:"users#create"

  get '/login', to:"session#new"

  post '/login', to:"session#create"

  delete '/logout', to:"session#destroy"

  # resourcesメソッドを使用する際にidを使用することができる書き方
  # idを指定せず複数定義する場合はmemberの代わりにcollectionメソッドを使用する
  resources :users do
    member do
      get :following, :followers
    end
  end

  resources :microposts, only: [:create, :destroy]

  resources :relationships, only: [:create, :destroy]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
