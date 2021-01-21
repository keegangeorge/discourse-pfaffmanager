# frozen_string_literal: true
class AddEncryptedDiscourseApiKeytoPfaffmanagerServers < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :encrypted_discourse_api_key, :string
  end
end
