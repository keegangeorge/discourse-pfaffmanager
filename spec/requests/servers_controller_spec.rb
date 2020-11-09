# frozen_string_literal: true
require 'rails_helper'

describe Pfaffmanager::ServersController do
  fab!(:user) { Fabricate(:user) }
  fab!(:admin) { Fabricate(:admin) }
  fab!(:another_user) { Fabricate(:user) }
  fab!(:trust_level_2) { Fabricate(:user, trust_level: TrustLevel[2]) }
  before do
    Jobs.run_immediately!
  end

it 'can list if no servers' do
  sign_in(user)
  get "/pfaffmanager/servers.json"
  expect(response.status).to eq(200)
  puts ("LIST: #{response.body}")
end

it 'can list when there is a server' do
  sign_in(user)
  hostname = 'bogus.invalid'
  s = Pfaffmanager::Server.createServerFromParams(user_id: user.id,
                                                  hostname: hostname , request_status: 'not updated')
  get "/pfaffmanager/servers.json"
  expect(response.status).to eq(200)
  json = response.parsed_body
  puts "server list: #{json}"
  expect(json['servers'][0]['hostname']).to eq(hostname)
  expect(json['servers'].count).to eq(1)
end

it 'cannot list if not logged in' do
  get "/pfaffmanager/servers.json"
  expect(response.status).to eq(403)
end

it 'can create a server' do
  sign_in(user)
  params = {}
  params['server'] = { user_id: user.id }
  post '/pfaffmanager/servers.json', params: params
  expect(response.status).to eq(200)
  server = response.parsed_body['server']
  puts "CREATESERVER: #{server} ----> #{server['id']}"
  expect(server["id"]).not_to eq nil
  new_server = Pfaffmanager::Server.find(server['id'])
  expect(new_server).not_to eq nil
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
