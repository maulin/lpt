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
    end
  end
    
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
