# frozen_string_literal: true

class CreatePfaffmanagerServer < ActiveRecord::Migration[6.0]
  def change
    create_table :pfaffmanager_servers do |t|
      t.string :hostname, null: false, index: true
      t.text :server_status_json
      t.timestamp :server_status_updated_at
      t.string :ssh_key_private
      t.string :ssh_key_public
      t.string :discourse_api_key
      t.string :do_api_key
      t.string :mg_api_key
      t.string :maxmind_license_key
      t.string :discourse_url
      t.text   :inventory
      t.text   :discourse_env
      t.text   :discourse_templates
      t.text   :discourse_plugins
      t.references :user
      t.timestamps
    end
  end
end
