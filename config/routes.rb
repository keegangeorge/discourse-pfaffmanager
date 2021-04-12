# frozen_string_literal: true
require_dependency "pfaffmanager_constraint"

Pfaffmanager::Engine.routes.draw do
  get "/" => "pfaffmanager#index", constraints: PfaffmanagerConstraint.new
  get "/servers" => "servers#index", constraints: PfaffmanagerConstraint.new
  get "/servers/:id" => "servers#show", constraints: PfaffmanagerConstraint.new
  put "/servers/:id" => "servers#update", constraints: PfaffmanagerConstraint.new
  put "/status/:id" => "servers#update_status", constraints: AdminConstraint.new
  post "/api_key/:id" => "servers#set_api_key", constraints: PfaffmanagerConstraint.new
  post "/upgrade/:id" => "servers#queue_upgrade", constraints: PfaffmanagerConstraint.new
  put "/install/:id" => "servers#install", constraints: PfaffmanagerConstraint.new
  get "/ssh_key/:id" => "serverkeys#get_pub_key"
  get "/ssh-key/:hostname" => "serverkeys#get_pub_key_by_hostname", constraints: { hostname: /[^\/]+/ }
  post "/servers" => "servers#create", constraints: PfaffmanagerConstraint.new
  get "/ssh-key/:hostname" => "serverkeys#get_pub_key_by_hostname", constraints: { hostname: /[^\/]+/ }
end

Discourse::Application.routes.append do
  mount ::Pfaffmanager::Engine, at: "/pfaffmanager"
  get "/ssh-key/:hostname" => "pfaffmanager/serverkeys#get_pub_key_by_hostname", constraints: { hostname: /[^\/]+/ }
end