# frozen_string_literal: true
require 'rails_helper'

describe Pfaffmanager::ActionsController do
  fab!(:user) { Fabricate(:user) }
  before do
    Jobs.run_immediately!
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/pfaffmanager/servers.json"
    expect(response.status).to eq(200)
  end

  it 'can create from params' do
    sign_in(Fabricate(:user))
    s=Pfaffmanager::Server.createServerFromParams(user_id: :user.id)
    puts "created #{s}, #{s.id} for #{:user.id}"
    expect(s.id).not_to be_nil
  end


end
