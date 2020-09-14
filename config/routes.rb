require_dependency "pfaffmanager_constraint"

Pfaffmanager::Engine.routes.draw do
  get "/" => "pfaffmanager#index", constraints: PfaffmanagerConstraint.new
  get "/actions" => "actions#index", constraints: PfaffmanagerConstraint.new
  get "/actions/:id" => "actions#show", constraints: PfaffmanagerConstraint.new
end
