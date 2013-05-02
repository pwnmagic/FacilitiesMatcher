FacilitiesMatcher::Application.routes.draw do
  get "hundred_percent_matches" => "matcher#hundred_percent_matches"
  get "ninenty_nine_till_eighty" => "matcher#ninenty_nine_till_eighty"
  get "seventy_nine_till_fifty" => "matcher#seventy_nine_till_fifty"
  get "followups/duplicates" => "matcher#followups", :defaults => {:filter => :mark_duplicate, :category => "Marked as duplicate"}
  get "followups/deletes" => "matcher#followups", :defaults => {:filter => :mark_delete, :category => "Marked for delete"}
  get "followups/reprocessed" => "matcher#followups", :defaults => {:filter => :mark_reprocess, :category => "Marked for reprocessing"}
  get "followups/add_to_dhis2" => "matcher#followups", :defaults => {:filter => :add_to_dhis2, :category => "To be added in DHIS2"}
  get "followups/error_in_dhis2_data" => "matcher#followups", :defaults => {:filter => :error_in_dhis2_data, :category => "To be reviewed in DHIS2"}
  get "followups/with_comments" => "matcher#followups", :defaults => {:filter => :comment, :category => "With comments"}

  get "followups" => "matcher#followups"
  get "facilities" => "matcher#facilities"

  get "below_fifty" => "matcher#below_fifty"
  get "by_district" => "matcher#by_district"
  get "search" => "matcher#search"
  get "promote/:id" => "matcher#promote", :as => :promote_facility
  get "demote/:id" => "matcher#demote", :as => :demote_facility
  get "followup/:id" => "matcher#followup", :as => :followup_facility
  get "mark_duplicate/:id" => "matcher#mark_duplicate", :as => :mark_duplicate
  get "mark_delete/:id" => "matcher#mark_delete", :as => :mark_delete
  get "mark_reprocess/:id" => "matcher#mark_reprocess", :as => :mark_reprocess
  get "add_to_dhis2/:id" => "matcher#add_to_dhis2", :as => :add_to_dhis2
  get "error_in_dhis2_data/:id" => "matcher#error_in_dhis2_data", :as => :error_in_dhis2_data
  put "comment/:id" => "matcher#comment", :as => :comment

  root :to => "matcher#summary"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
