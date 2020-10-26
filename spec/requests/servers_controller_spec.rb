# frozen_string_literal: true
require 'rails_helper'

describe Pfaffmanager::ActionsController do
  fab!(:user) { Fabricate(:user) }
  fab!(:another_user) { Fabricate(:user) }
  fab!(:trust_level_2) { Fabricate(:user, trust_level: TrustLevel[2]) }
  before do
    Jobs.run_immediately!
    stub_request(:get, "https://api.mailgun.net/v3/domains").
    with(
      headers: {
     'Accept'=>'*/*',
     'Host'=>'api.mailgun.net',
     'User-Agent'=>'excon/0.76.0'
      }).
    to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://api.digitalocean.com/v2/account").
    with(
      headers: {
     'Authorization'=>'Bearer do-boguskey',
     'Host'=>'api.digitalocean.com'
      }).
    to_return(status: 200, body: '{"account": { "status":"active"}}', headers: {})

end

  it 'can list' do
    sign_in(user)
    get "/pfaffmanager/servers.json"
    expect(response.status).to eq(200)
  end

  it 'can create from params' do
    sign_in(user)
    puts "create from params user id #{user}"
    s=Pfaffmanager::Server.createServerFromParams(user_id: user.id)
    puts "from params created #{s}, #{s.id} for #{user.id}"
    expect(s.id).not_to be_nil
  end

  it 'can create for  user_id' do
    sign_in(user)
    s=Pfaffmanager::Server.createServerForUser(user.id)
    puts "create for user id created #{s}, #{s.id} for #{user.id}"
    expect(s.id).not_to be_nil
  end

  it 'can create from params with mg api key' do
    sign_in(user)
    s=Pfaffmanager::Server.createServerFromParams(user_id: user.id, mg_api_key: 'mg_boguskey')
    puts "created #{s}, #{s.id} for #{user.id}"
    expect(s.id).not_to be_nil
  end

  it 'can create from params with do api key' do
    sign_in(user)
    s=Pfaffmanager::Server.createServerFromParams(user_id: user.id, do_api_key: 'do-boguskey')
    puts "created #{s}, #{s.id} for #{user.id}"
    expect(s.id).not_to be_nil
  end


end
