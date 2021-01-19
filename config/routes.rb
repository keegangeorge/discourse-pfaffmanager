# frozen_string_literal: true
require_dependency "pfaffmanager_constraint"

Pfaffmanager::Engine.routes.draw do
  get "/" => "pfaffmanager#index", constraints: PfaffmanagerConstraint.new
  get "/actions" => "actions#index", constraints: PfaffmanagerConstraint.new
  get "/actions/:id" => "actions#show", constraints: PfaffmanagerConstraint.new
  get "/servers" => "servers#index", constraints: PfaffmanagerConstraint.new
  get "/servers/:id" => "servers#show", constraints: PfaffmanagerConstraint.new
  put "/servers/:id" => "servers#update", constraints: PfaffmanagerConstraint.new
  post "/api_key/:id" => "servers#set_api_key", constraints: PfaffmanagerConstraint.new
  post "/upgrade/:id" => "servers#queue_upgrade", constraints: PfaffmanagerConstraint.new
  get "ssh_key/:id" => "serverkeys#get_pub_key"
  post "/servers" => "servers#create", constraints: PfaffmanagerConstraint.new
  get "/githubs" => "githubs#index", constraints: PfaffmanagerConstraint.new
  get "/githubs/:id" => "githubs#show", constraints: PfaffmanagerConstraint.new
  namespace :user do
    resources :servers
  end
end
