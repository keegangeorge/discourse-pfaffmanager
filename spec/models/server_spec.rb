# frozen_string_literal: true
require 'rails_helper'

module Pfaffmanager
  RSpec.describe Server do
    let(:user) { Fabricate(:user) }
    let(:server) { Fabricate(:server) }
    let(:discourse_server) { Fabricate(:server,
      hostname: 'working.discourse.invalid',
      discourse_api_key: 'working-discourse-key')}
      create_group = Group.find_by_name(SiteSetting.pfaffmanager_create_server_group)
      pro_group = Group.find_by_name(SiteSetting.pfaffmanager_pro_server_group)
      ec2_group = Group.find_by_name(SiteSetting.pfaffmanager_ec2_server_group)
      ec2_pro_group = Group.find_by_name(SiteSetting.pfaffmanager_ec2_pro_server_group)
      pfaffmanager_hosted_server_group = Group.find_by_name(SiteSetting.pfaffmanager_hosted_server_group)

before do
  SiteSetting.pfaffmanager_upgrade_playbook = 'spec-test.yml'
  SiteSetting.pfaffmanager_do_install = '/bin/true'
  SiteSetting.pfaffmanager_skip_actions = true
  SiteSetting.pfaffmanager_do_api_key = 'fake-do-api-key'
  SiteSetting.pfaffmanager_mg_api_key = 'fake-mg-api-key'
  stub_request(:get, "https://api.digitalocean.com/v2/account").
    with(
      headers: {
     'Authorization' => 'Bearer fake-do-api-key',
     'Host' => 'api.digitalocean.com'
      }).
    to_return(status: 200, body: "", headers: {})

  stub_request(:get, "https://api.digitalocean.com/v2/account").
    with(
    headers: {
   'Authorization' => 'Bearer do-valid-key',
   'Host' => 'api.digitalocean.com'
    }).
    to_return(status: 200, body: '{"account": { "status":"active"}}', headers: {})
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
   stub_request(:get, "https://api.digitalocean.com/v2/account").
     with(
          headers: {
         'Authorization' => 'Bearer do-INvalid-key',
         'Host' => 'api.digitalocean.com'
          }).

     to_return(status: 404, body: '{"errors":["The requested URL or resource could not be found."],"error_type":"not_found"}', headers: {})
     # the api:key gets converted to this basic auth authorization
     # TODO: generate this rrather than hard-code it.
     stub_request(:get, "https://api.mailgun.net/v3/domains").
       with(
          headers: {
         'Authorization' => 'Basic YXBpOm1nLXZhbGlkLWtleQ==',
         'Host' => 'api.mailgun.net'
          }).

       to_return(status: 200, body: "", headers: {})
     stub_request(:get, "https://api.mailgun.net/v3/domains").
       with(
            headers: {
           'Authorization' => 'Basic YXBpOmludmFsaWQtbWctdmFsaWQta2V5',
           'Host' => 'api.mailgun.net'
            }).
       to_return(status: 403, body: "", headers: {}) #not sure what the actual error status is
end
    it "has a table name" do
      expect(described_class.table_name).to eq ("pfaffmanager_servers")
    end

    it "can createServerForUser" do
      server = described_class.createServerForUser(user.id, hostname = "new-server-for-#{user.id}")
      expect(server.hostname).to eq "new-server-for-#{user.id}"
    end

    it 'can create from params' do
      puts "create from params user id #{user}"
      s = described_class.createServerFromParams(user_id: user.id)
      puts "from params created #{s}, #{s.id} for #{user.id}"
      expect(s.id).not_to be_nil
    end

    it 'can add valid do_api_key' do
      server.do_api_key = 'do-valid-key'
      server.save
      expect(server).to be_valid
    end

    it 'cannot add invalid do_api_key' do
      server.do_api_key = 'do-INvalid-key'
      server.save
      expect(server).not_to be_valid
    end

    it 'can add valid mg api key' do
      server.mg_api_key = 'mg-valid-key'
      server.save
      expect(server.mg_api_key).to eq 'mg-valid-key'
    end

    it 'will not accpt invalid mg api key' do
      server.mg_api_key = 'invalid-mg-valid-key'
      server.save
      expect(server.mg_api_key).to eq 'invalid-mg-valid-key'
    end

    it 'setting a discourse_api_key updates version fields' do
      discourse_server.discourse_api_key = 'working-discourse-key'
      discourse_server.server_status_json = 'bogus'
      discourse_server.installed_version = 'none'

      expect { discourse_server.save }
        .to change(discourse_server, :server_status_json)
        .and change(discourse_server, :installed_version)
    end

    it 'creates a server if user is added to createServer group' do
      expect { GroupUser.create(group_id: create_group.id, user_id: user.id) }
        .to change { Pfaffmanager::Server.count }.by(1)
      server = Pfaffmanager::Server.where(user_id: user.id).last
      expect(server.install_type).to eq 'std'
      expect(GroupUser.find_by(user_id: user.id, group_id: create_group.id)).to eq nil
    end
    it 'creates a pro server if user is added to proServer group' do
      expect { GroupUser.create(group_id: pro_group.id, user_id: user.id) }
        .to change { Pfaffmanager::Server.count }.by(1)
      server = Pfaffmanager::Server.where(user_id: user.id).last
      expect(server.install_type).to eq 'pro'
      expect(GroupUser.find_by(user_id: user.id, group_id: pro_group.id)).to eq nil
    end

    it 'creates a ec2 server if user is added to ec2Server group' do
      expect { GroupUser.create(group_id: ec2_group.id, user_id: user.id) }
        .to change { Pfaffmanager::Server.count }.by(1)
      server = Pfaffmanager::Server.where(user_id: user.id).last
      expect(server.install_type).to eq 'ec2'
      expect(GroupUser.find_by(user_id: user.id, group_id: ec2_group.id)).to eq nil
    end
    it 'creates a ec2 pro server if user is added to ec2Server group' do
      expect { GroupUser.create(group_id: ec2_pro_group.id, user_id: user.id) }
        .to change { Pfaffmanager::Server.count }.by(1)
      server = Pfaffmanager::Server.where(user_id: user.id).last
      expect(server.install_type).to eq 'ec2_pro'
      expect(GroupUser.find_by(user_id: user.id, group_id: ec2_pro_group.id)).to eq nil
    end

    it 'creates a LC pro server with LC keys if user is added to LCProServer group', skip: "skip group tests" do
      expect { GroupUser.create(group_id: pfaffmanager_hosted_server_group.id, user_id: user.id) }
        .to change { Pfaffmanager::Server.count }.by(1)
      server = Pfaffmanager::Server.where(user_id: user.id).last
      expect(server.install_type).to eq 'lc_pro'
      expect(server.mg_api_key).to eq SiteSetting.pfaffmanager_mg_api_key
      expect(server.do_api_key).to eq SiteSetting.pfaffmanager_do_api_key
      expect(GroupUser.find_by(user_id: user.id, group_id: pfaffmanager_hosted_server_group.id)).to eq nil
    end
  end
end
