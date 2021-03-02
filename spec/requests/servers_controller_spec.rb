# frozen_string_literal: true
require 'rails_helper'

describe Pfaffmanager::ServersController do
  fab!(:user) { Fabricate(:user, username: 'pfaffmanager_user') }
  fab!(:create_user) { Fabricate(:user) }
  fab!(:admin) { Fabricate(:admin) }
  fab!(:another_user) { Fabricate(:user) }
  fab!(:trust_level_2) { Fabricate(:user, trust_level: TrustLevel[2]) }
  # fab!(:pfaffmanager_create_server_group) { Fabricate(:group, name: SiteSetting.pfaffmanager_create_server_group) }
  # fab!(:pfaffmanager_unlimited_server_group) { Fabricate(:group, name: SiteSetting.pfaffmanager_unlimited_server_group) }
  # fab!(:pfaffmanager_server_manager_group) { Fabricate(:group, name: SiteSetting.pfaffmanager_server_manager_group) }
  # fab!(:pfaffmanager_pro_server_group) { Fabricate(:group, name: SiteSetting.pfaffmanager_pro_server_group) }
  # fab!(:pfaffmanager_ec2_server_group) { Fabricate(:group, name: SiteSetting.pfaffmanager_ec2_server_group) }
  # fab!(:pfaffmanager_ec2_pro_server_group) { Fabricate(:group, name: SiteSetting.pfaffmanager_ec2_pro_server_group) }
  # fab!(:pfaffmanager_hosted_server_group) { Fabricate(:group, name: SiteSetting.pfaffmanager_hosted_server_group) }

  SiteSetting.pfaffmanager_upgrade_playbook = 'spec-test.yml'
  # SiteSetting.pfaffmanager_do_install = 'true'

  # create_server_group_name = "create_server"
  # group = Group.create(name: create_server_group_name)
  # looking = Group.find_by_name(group.name)
  # SiteSetting.pfaffmanager_create_server_group = create_server_group_name
  # unlimited_server_group_name = "unlimited_servers"
  # unlimited_group = Group.create(name: unlimited_server_group_name)
  # SiteSetting.pfaffmanager_unlimited_server_group = unlimited_server_group_name
  # server_manager_group_name = "UpgradeServers"
  # server_manager_group = Group.create(name: server_manager_group_name)
  # SiteSetting.pfaffmanager_server_manager_group = server_manager_group_name

  #pro_server_group_name = "ProServer"
  #pro_server_group = Group.create(name: pro_server_group_name)
  #SiteSetting.pfaffmanager_pro_server_group(pro_server_group_name)

  before do
    Jobs.run_immediately!
    stub_request(:get, "https://working.discourse.invalid/admin/dashboard.json").
      with(
        headers: {
          'Api-Key' => 'working-discourse-key',
          'Api-Username' => 'system',
          'Host' => 'working.discourse.invalid'
        }).
      to_return(status: 200, body: '{
      "updated_at": "2020-10-26T17:21:00.678Z",
      "version_check": {
      "installed_version": "2.6.0.beta4",
      "installed_sha": "abb00c3780987678fbc6f21ab0c8e46ac297ca75",
      "installed_describe": "v2.6.0.beta4 +56",
      "git_branch": "tests-passed",
      "updated_at": "2020-10-26T17:01:08.197Z",
      "latest_version": "2.6.0.beta4",
      "critical_updates": false,
      "missing_versions_count": 0,
      "stale_data": false
      }}', headers: {})
  end

  describe "no servers defined" do
    it 'can list if no servers' do
      sign_in(user)
      get "/pfaffmanager/servers.json"
      expect(response.status).to eq(200)
      json = response.parsed_body
      expect(json['servers'].length).to eq(0)
    end
    it 'cannot list if not logged in' do
      get "/pfaffmanager/servers.json"
      expect(response.status).to eq(403)
    end

  end

  describe "servers" do
    let!(:installed_server) { Fabricate(:server,
      user: user,
      hostname: 'working.discourse.invalid',
      discourse_api_key: 'working-discourse-key',
      install_type: 'std')}
    let!(:new_server) { Fabricate(:server,
        user: user,
        hostname: 'nothing.discourse.invalid',
        install_type: 'std',
        droplet_size: "missing")}

  it 'can list when there is a server' do
    puts "can list discourse server hostname: #{new_server.hostname} host user: #{new_server.user_id}. User #{user.id} "
    servers = Pfaffmanager::Server.all
    puts "XXXY got #{servers.count} servers"
    puts "First server: #{servers.first['hostname']} has #{servers.first['user_id']}"
    sign_in(user)
    puts "Userid: #{user.id} #{user.username}"
    #TODO: should fabricate this
    get "/pfaffmanager/servers.json"
    json = response.parsed_body
    expect(response.status).to eq(200)
    expect(json['servers'].count).to eq(2)
  end

  it 'cannot list if not logged in' do
    get "/pfaffmanager/servers.json"
    expect(response.status).to eq(403)
  end

# it 'CreateServer group can create a server and be removed from group' do
#   group = Group.find_by_name(SiteSetting.pfaffmanager_create_server_group)
#   group.add(user)
#   sign_in(user)
#   params = {}
#   params['server'] = { user_id: user.id }
#   post '/pfaffmanager/servers.json', params: params
#   expect(response.status).to eq(200)
#   server = response.parsed_body['server']
#   expect(response.parsed_body).to eq "broken"
#   expect(server["id"]).not_to eq nil
#   new_server = Pfaffmanager::Server.find(server['id'])
#   expect(new_server).not_to eq nil
#   expect(group.users.where(id: user.id)).to be_empty
# end

it 'UnlimitedCreate group can create a server and NOT be removed from group' do
  group = Group.find_by_name(SiteSetting.pfaffmanager_unlimited_server_group)
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
  expect(group.users.where(id: user.id)).not_to be_empty
end

it 'Admin can create a server' do
  sign_in(admin)
  params = {}
  params['server'] = { user_id: admin.id }
  post '/pfaffmanager/servers.json', params: params
  expect(response.status).to eq(200)
  server = response.parsed_body['server']
  expect(server["id"]).not_to eq nil
  new_server = Pfaffmanager::Server.find(server['id'])
  expect(new_server).not_to eq nil
end

it 'CreateServer fails if not in create group' do
  #group = Group.find_by_name(SiteSetting.pfaffmanager_create_server_group)
  sign_in(user)
  params = {}
  params['server'] = { user_id: user.id }
  post '/pfaffmanager/servers.json', params: params
  expect(response.status).to eq(200)
  server = response.parsed_body['server']
  expect(server["id"]).to eq nil
end

it 'will upgrade for server owner' do
  sign_in(user)
    path = "/pfaffmanager/upgrade/#{installed_server.id}.json"
    post path
    expect(user.id).to eq(installed_server.user_id)
    expect(response.status).to eq(200)
    expect(response.parsed_body['success']).to eq "OK"
    expect { installed_server.reload }.to change { installed_server.request_status }
    expect(response.status).to eq(200)
end

  it 'will upgrade for an admin' do
    puts 'starting upgrade for admin'
    sign_in(admin)
    path = "/pfaffmanager/upgrade/#{installed_server.id}.json"
    puts 'posting upgrade for admin'
    post path
    expect(admin.id).not_to eq(installed_server.user_id)
    expect(response.status).to eq(200)
    expect(response.parsed_body['success']).to eq "OK"
    expect { installed_server.reload }.to change { installed_server.request_status }
  end

it 'refuses to upgrade for user who does not own server' do
  sign_in(another_user)
  post "/pfaffmanager/upgrade/#{installed_server.id}.json"
  expect(another_user.id).not_to eq(installed_server.user_id)
  expect(response.status).to eq(403)
  expect(response.parsed_body['failed']).to eq "FAILED"
end

it 'will do digital ocean install for server owner' do
  sign_in(user)
  new_server.install_type = 'pro'
  new_server.save
  path = "/pfaffmanager/install/#{new_server.id}.json"
  put path
  expect(response.status).to eq(200)
  expect(response.parsed_body['success']).to eq "OK"
end

it 'will not do digital ocean install if not a DO install type' do
  sign_in(user)
  new_server.install_type = 'none'
  new_server.save
  path = "/pfaffmanager/install/#{new_server.id}.json"
  put path
  expect(response.status).to eq(501)
  expect(response.parsed_body['failed']).to eq "FAILED"
end

it 'will digital ocean install for an admin' do
  new_server.install_type = 'pro'
  new_server.save
  sign_in(admin)
  path = "/pfaffmanager/install/#{new_server.id}.json"
  put path
  expect(admin.id).not_to eq(new_server.user_id)
  expect(response.status).to eq(200)
  expect(response.parsed_body['success']).to eq "OK"
end

it 'refuses to install for user who does not own server' do
  new_server.install_type = 'pro'
  new_server.save
  sign_in(another_user)
  put "/pfaffmanager/install/#{new_server.id}.json"
  expect(another_user.id).not_to eq(new_server.user_id)
  expect(response.status).to eq(403)
  expect(response.parsed_body['failed']).to eq "FAILED"
end

# TODO: add this back
# it 'server manager cannot start upgrade if one is running' do
#   group = Group.find_by_name(SiteSetting.pfaffmanager_server_manager_group)
#     group.add(user)
#     sign_in(user)
#     params = {}
#     params['server'] = { id: discourse_server.id, user_id: user.id, request: 1 }
#     put "/pfaffmanager/servers/#{discourse_server.id}.json", params: params
#     expect(response.status).to eq(200)
#     expect(response.parsed_body['success']).to eq "OK"
#     discourse_server.reload
#     expect(discourse_server.request).to eq -1
#     expect(discourse_server.last_action).to eq 'Process rebuild'
#     rebuild_status = 'spec testing'
#     discourse_server.last_action = rebuild_status
#     put "/pfaffmanager/servers/#{discourse_server.id}.json", params: params
#     expect(discourse_server.last_action).to eq rebuild_status
# end

it 'can get a ssh key even if logged in as another user' do
  sign_in(user)
  get "/pfaffmanager/ssh-key/#{new_server.id}"
  expect(response.status).to eq(200)
  expect(response.body).to include('ssh-rsa')
end

it 'can update smtp parameters' do
  sign_in(user)
  smtp_user = 'theuser'
  smtp_password = "smtp-pw"
  smtp_host = 'smtphost.com'
  smtp_port = '1234'
  smtp_notification_email = 'nobody@nowhere.com'
  params = { server: { smtp_host: smtp_host,
                       smtp_password: smtp_password,
                       smtp_port: smtp_port,
                       smtp_user: smtp_user,
                       smtp_notification_email: smtp_notification_email
                      }
            }
  put "/pfaffmanager/servers/#{new_server.id}.json", params: params
  expect(response.status).to eq(200)
  new_server.reload
  expect(new_server.smtp_host).to eq(smtp_host)
  expect(new_server.smtp_password).to eq(smtp_password)
  expect(new_server.smtp_user).to eq(smtp_user)
  expect(new_server.smtp_port).to eq(smtp_port)
  expect(new_server.smtp_notification_email).to eq(smtp_notification_email)
end

it 'does not allow status to be updated via API' do
  sign_in(admin)
    new_status = 'new status'
    fake_status = 'not a status'
    new_server.request_status = fake_status
    new_server.save
    params = {}
    params['server'] = { request_status: new_status }
    put "/pfaffmanager/servers/#{new_server.id}.json", params: params
    expect(response.status).to eq(200)
    expect(response.parsed_body['server']['request_status']).to eq(fake_status)
end

it 'users cannot update status' do
  sign_in(user)
    new_status = 'new status'
    params = {}
    params = { request_status: new_status }
    put "/pfaffmanager/servers/#{new_server.id}.json", params: params
    expect(response.status).to eq(400)
    expect { new_server.reload }
      .not_to change { new_server.request_status }
end

it 'can get an ssh pub key by server id' do
  get "/pfaffmanager/ssh-key/#{new_server.id}"
  expect(response.body).to include "ssh-rsa"
end

skip 'can get an ssh pub key by server hostname' do
  get "/pfaffmanager/ssh-key/#{new_server.hostname}"
  expect(response.body).to include "ssh-rsa"
end

it 'allows status to be updated via update status route' do
  sign_in(admin)
    new_status = 'doing something important'
    params = {}
    params = { request_status: new_status }
    puts "about to put to /pfaffmanager/status for #{new_server.id}"
    put "/pfaffmanager/status/#{new_server.id}.json", params: params
    expect(response.status).to eq(200)
    expect(response.parsed_body['success']).to eq "OK"
    expect { new_server.reload }
      .to change { new_server.request_status }
end
  end
end
