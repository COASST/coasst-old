ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # map.root :controller => "welcome"
  # map the homepage
  #map.home '', :controller => "site", :action => 'index'
#  map.root :controller => "site"
  map.home '', :controller => "site", :action => 'index'
  map.root :controller => "site", :action => 'index'

  # accept plural cases
  map.connect "regions/", :controller => "region"
  map.connect "regions/:id", :controller => "region", :action => "show"
  
  # sparkline controller hook-up
  map.graphs "graphs/:action/:id/image.png", :controller => "graphs"

  # not a survey data passing
  map.connect "data/step_not_survey/:id/:status", :controller => "data", :action => :step_not_survey

  # map file exports
  map.connect "admin/export/:filename", {:controller => :admin, :action => :export, 
    :requirements => {:filename => /.*/}}

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
