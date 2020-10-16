# frozen_string_literal: true
class AddDataTypeToPfaffmanagerServers < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :request_result, :string
  end
end
