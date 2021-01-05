# frozen_string_literal: true
require 'rails_helper'

describe Pfaffmanager::ActionsController do
  before do
    Jobs.run_immediately!
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/pfaffmanager/actions/list.json"
    expect(response.status).to eq(200)
  end
end
