Lpt::Application.routes.draw do

  root :to => 'hosts#index'
  
  devise_for :users

  resources :versions,:constraints => { :id => /.*/ }

  resources :hosts, :constraints => { :id => /.*/ } do
    #this way we can scan a collection of hosts as well as a single host
    get 'scan', :on => :member 
    collection do
      get 'scan'
    end
    resources :installations
    resource :os
    resource :arch
  end

   
  resources :packages, :constraints => { :id => /.*/ } do
    resources :installations
    resources :versions
    resources :arches
  end
  
  resources :installations

  resources :jobs do
    collection do
      put 'clear'
      post 'reset_all'
    end
    #post 'reset_status', :on=> :member
  end
  
  resources :repos do
    get 'scan', :on => :member
    collection do
      get 'scan'
    end
  end
    
    
end
