ActionController::Routing::Routes.draw do |map|
  map.resources :users, 
    :collection => {:load_data => :get, :select_fields => :post, :parse_data => :post, :flush_data => :delete}
  map.root :controller => "users"
end
