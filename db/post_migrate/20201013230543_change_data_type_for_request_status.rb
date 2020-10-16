# frozen_string_literal: true
class ChangeDataTypeForRequestStatus < ActiveRecord::Migration[6.0]
  def change
    remove_column :pfaffmanager_servers, :request_status
    add_column :pfaffmanager_servers, :request_status, :string
  end
end
