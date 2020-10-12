require_dependency "pfaffmanager_constraint"

Pfaffmanager::Engine.routes.draw do
  get "/" => "pfaffmanager#index", constraints: PfaffmanagerConstraint.new
  get "/actions" => "actions#index", constraints: PfaffmanagerConstraint.new
  get "/actions/:id" => "actions#show", constraints: PfaffmanagerConstraint.new
  get "/servers" => "servers#index", constraints: PfaffmanagerConstraint.new
  get "/servers/:id" => "servers#show", constraints: PfaffmanagerConstraint.new
  put "/servers/:id" => "servers#update", constraints: PfaffmanagerConstraint.new
  post "/servers" => "servers#create", constraints: PfaffmanagerConstraint.new
  get "/githubs" => "githubs#index", constraints: PfaffmanagerConstraint.new
  get "/githubs/:id" => "githubs#show", constraints: PfaffmanagerConstraint.new
end
