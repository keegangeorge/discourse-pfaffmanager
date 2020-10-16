# frozen_string_literal: true
class AddStatusFieldsToPfaffmanagerServer < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :request, :string
    add_column :pfaffmanager_servers, :request_created_at, :datetime
    add_column :pfaffmanager_servers, :request_status, :string
    add_column :pfaffmanager_servers, :request_status_updated_at, :datetime
  end
end
