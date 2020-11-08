# frozen_string_literal: true
require 'rails_helper'

module Pfaffmanager
  RSpec.describe Server do
    let(:user) { Fabricate(:user) }

    it "has a table name" do
      expect(described_class.table_name).to eq ("pfaffmanager_servers")
    end

    # it "creates" do
    #   server = described_class.create_server(user, stripe_customer)
    #   expect(customer.customer_id).to eq 'cus_id4567'
    #   expect(customer.user_id).to eq user.id
    # end

    # it "has a user scope" do
    #   described_class.create_customer(user, stripe_customer)
    #   customer = described_class.find_user(user)
    #   expect(customer.customer_id).to eq 'cus_id4567'
    # end
  end
end

describe Pfaffmanager::Server do
  fab!(:user) { Fabricate(:user) }
  fab!(:admin) { Fabricate(:admin) }
  fab!(:another_user) { Fabricate(:user) }
  fab!(:trust_level_2) { Fabricate(:user, trust_level: TrustLevel[2]) }
  let(:server) { Fabricate(:server) }
  let(:discourse_server) { Pfaffmanager::Server.create(user_id: user.id,
                                                       hostname: 'bogus.discourse.invalid',
                                                       discourse_api_key: 'bogus-discourse-key')}

  before do
    Jobs.run_immediately!
    stub_request(:get, "https://api.mailgun.net/v3/domains").
      with(
        headers: {
          'Accept' => '*/*',
          'Host' => 'api.mailgun.net',
          'User-Agent' => 'excon/0.76.0'
        }).
      to_return(status: 200, body: "", headers: {})
      stub_request(:get, "https://api.digitalocean.com/v2/account").
        with(
        headers: {
          'Authorization' => 'Bearer do-valid-key',
          'Host' => 'api.digitalocean.com'
        }).
        to_return(status: 200, body: '{"account": { "status":"active"}}', headers: {})
      stub_request(:get, "https://api.digitalocean.com/v2/account").
        with(
        headers: {
          'Authorization' => 'Bearer do-bogus-key',
          'Host' => 'api.digitalocean.com'
        }).
        to_return(status: 401, body: '{"account": { "status":"broken"}}', headers: {})
    stub_request(:get, "https://bogus.discourse.invalid/admin/dashboard.json").
      with(
        headers: {
          'Api-Key' => 'bogus-discourse-key',
          'Api-Username' => 'system',
          'Host' => 'bogus.discourse.invalid'
        }).
      to_return(status: 200, body: '{
      updated_at: "2020-10-26T17:21:00.678Z",
      version_check: {
      installed_version: "2.6.0.beta4",
      installed_sha: "abb00c3780987678fbc6f21ab0c8e46ac297ca75",
      installed_describe: "v2.6.0.beta4 +56",
      git_branch: "tests-passed",
      updated_at: "2020-10-26T17:01:08.197Z",
      latest_version: "2.6.0.beta4",
      critical_updates: false,
      missing_versions_count: 0,
      stale_data: false
      }}', headers: {})

  end

  # TODO: these are really specs for the model, not the controller

  it 'can create from params' do
    puts "create from params user id #{user}"
    s = Pfaffmanager::Server.createServerFromParams(user_id: user.id)
    puts "from params created #{s}, #{s.id} for #{user.id}"
    expect(s.id).not_to be_nil
  end

  it 'can create for  user_id' do
    s = Pfaffmanager::Server.createServerForUser(user.id)
    puts "create for user id created #{s}, #{s.id} for #{user.id}"
    expect(s.id).not_to be_nil
  end

  it 'can add do_api_key' do
    server.do_api_key = 'do-valid-key'
    server.save
    expect(server).to be_valid
  end

  # it 'can create from params with mg api key' do
  #   s=Pfaffmanager::Server.createServerFromParams(user_id: user.id, mg_api_key: 'mg_boguskey')
  #   puts "created #{s}, #{s.id} for #{user.id}"
  #   expect(s.id).not_to be_nil
  # end

  # it 'can create from params with do api key' do
  #   s=Pfaffmanager::Server.createServerFromParams(user_id: user.id, do_api_key: 'do-boguskey')
  #   puts "created #{s}, #{s.id} for #{user.id}"
  #   expect(s.id).not_to be_nil
  # end

  it 'can have a discourse_api_key and update version fields' do
    expect(discourse_server.server_status_json).not_to be_nil
    expect(discourse_server.installed_version).to eq('2.6.0.beta4')
    expect(discourse_server.installed_sha = 'abb00c3780987678fbc6f21ab0c8e46ac297ca75')
    expect(discourse_server.git_branch = 'tests-passed')
  end

end
