# frozen_string_literal: true
require 'rails_helper'

describe Pfaffmanager::ServersController do
  fab!(:user) { Fabricate(:user) }
  fab!(:create_user) { Fabricate(:user) }
  fab!(:admin) { Fabricate(:admin) }
  fab!(:another_user) { Fabricate(:user) }
  fab!(:trust_level_2) { Fabricate(:user, trust_level: TrustLevel[2]) }
  create_server_group_name = "create_server"
  group = Group.create(name: create_server_group_name)
  puts "Group made: #{group.name}"
  looking = Group.find_by_name(group.name)
  puts "FOund #{looking.id}"
  SiteSetting.pfaffmanager_create_server_group = create_server_group_name

  before do
    Jobs.run_immediately!
  end

it 'can list if no servers' do
  sign_in(user)
  get "/pfaffmanager/servers.json"
  expect(response.status).to eq(200)
end

it 'can list when there is a server' do
  sign_in(user)
  hostname = 'bogus.invalid'
  #TODO: should fabricate this
  s = Pfaffmanager::Server.createServerFromParams(user_id: user.id,
                                                  hostname: hostname , request_status: 'not updated')
  get "/pfaffmanager/servers.json"
  expect(response.status).to eq(200)
  json = response.parsed_body
  expect(json['servers'][0]['hostname']).to eq(hostname)
  expect(json['servers'].count).to eq(1)
end

it 'cannot list if not logged in' do
  get "/pfaffmanager/servers.json"
  expect(response.status).to eq(403)
end

it 'CreateServer group can create a server and be removed from group' do
  group = Group.find_by_name(SiteSetting.pfaffmanager_create_server_group)
  group.add(user)
  sign_in(user)
  params = {}
  params['server'] = { user_id: user.id }
  post '/pfaffmanager/servers.json', params: params
  expect(response.status).to eq(200)
  server = response.parsed_body['server']
  expect(server["id"]).not_to eq nil
  new_server = Pfaffmanager::Server.find(server['id'])
  expect(new_server).not_to eq nil
  expect(group.users.where(id: user.id)).to be_empty
end

it 'CreateServer fails if not in create group' do
  group = Group.find_by_name(SiteSetting.pfaffmanager_create_server_group)
  sign_in(user)
  params = {}
  params['server'] = { user_id: user.id }
  post '/pfaffmanager/servers.json', params: params
  expect(response.status).to eq(200)
  server = response.parsed_body['server']
  expect(server["id"]).to eq nil
end

it 'can update status' do
  request_status = 'new status'
  sign_in(admin)
  s = Pfaffmanager::Server.createServerFromParams(user_id: user.id,
                                                  hostname: 'bogus.invalid' , request_status: 'not updated')
  puts "can update status created server id: #{s.id}"
  params = { server: { git_branch: 'not' } }

  expect {
    put "/pfaffmanager/servers/#{s.id}", params: params
  }.not_to change { s.request_status }
  #expect(s.git_branch).to eq('new status')
  expect(response.status).to eq(200)
  #assigns(:request_status).should eq(request_status)
end

  # it 'can update status' do
  #   request_status = 'new status'
  #   s=Pfaffmanager::Server.createServerFromParams(user_id: user.id,
  #                                                 hostname: 'bogus.invalid' , request_status: 'not updated')
  #   puts "can update status created server id: #{s.id}"
  #   params = {server: {git_branch: 'not'}}

  #   expect {
  #     puts "/pfaffmanager/servers/#{s.id}", params: params
  #   }.not_to change { s.request_status }
  #   #expect(s.git_branch).to eq('new status')
  #   expect(response.status).to eq(200)
  #   #assigns(:request_status).should eq(request_status)
  # end

end
