require 'rails_helper'

describe Pfaffmanager::GithubsController do
  before do
    Jobs.run_immediately!
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/pfaffmanager/list.json"
    expect(response.status).to eq(200)
  end
end
