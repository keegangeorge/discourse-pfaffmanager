# frozen_string_literal: true
require_dependency "pfaffmanager_constraint"

Pfaffmanager::Engine.routes.draw do
  get "/pfaffmanager/" => "pfaffmanager#index", constraints: PfaffmanagerConstraint.new
  get "/pfaffmanager/servers" => "servers#index", constraints: PfaffmanagerConstraint.new
  get "/pfaffmanager/servers/:id" => "servers#show", constraints: PfaffmanagerConstraint.new
  put "/pfaffmanager/servers/:id" => "servers#update", constraints: PfaffmanagerConstraint.new
  put "/pfaffmanager/status/:id" => "servers#update_status", constraints: AdminConstraint.new
  post "/pfaffmanager/api_key/:id" => "servers#set_api_key", constraints: PfaffmanagerConstraint.new
  post "/pfaffmanager/upgrade/:id" => "servers#queue_upgrade", constraints: PfaffmanagerConstraint.new
  put "/pfaffmanager/install/:id" => "servers#install", constraints: PfaffmanagerConstraint.new
  get "/pfaffmanager/ssh_key/:id" => "serverkeys#get_pub_key"
  get "/pfaffmanager/ssh-key/:hostname" => "serverkeys#get_pub_key_by_hostname", constraints: { hostname: /[^\/]+/ }
  post "/pfaffmanager/servers" => "servers#create", constraints: PfaffmanagerConstraint.new
  get "/ssh-key/:hostname" => "serverkeys#get_pub_key_by_hostname", constraints: { hostname: /[^\/]+/ }
end

Discourse::Application.routes.append do
  mount ::Pfaffmanager::Engine, at: "/"
end
