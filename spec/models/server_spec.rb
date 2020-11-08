# frozen_string_literal: true
require 'rails_helper'

module Pfaffmanager
  RSpec.describe Server do
    let(:user) { Fabricate(:user) }
    let(:server) { Fabricate(:server) }
    let(:discourse_server) { Fabricate(:server,
      hostname: 'working.discourse.invalid',
      discourse_api_key: 'working-discourse-key')}

before do
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

    it 'can add do_api_key' do
      server.do_api_key = 'do-valid-key'
      server.save
      expect(server).to be_valid
    end

    it 'setting an empty discourse_api_key does not update version fields' do
      server.discourse_api_key = ''
      server.save
      expect(server.server_status_json).to be_nil
      expect(server.installed_version).not_to eq('2.6.0.beta4')
      expect(server.installed_sha).not_to eq 'abb00c3780987678fbc6f21ab0c8e46ac297ca75'
    end
    it 'setting a discourse_api_key updates version fields' do
      discourse_server.discourse_api_key = 'working-discourse-key'
      discourse_server.save
      expect(discourse_server.server_status_json).not_to be_nil
      expect(discourse_server.installed_version).to eq('2.6.0.beta4')
      expect(discourse_server.installed_sha).to eq 'abb00c3780987678fbc6f21ab0c8e46ac297ca75'
    end

  end
end
