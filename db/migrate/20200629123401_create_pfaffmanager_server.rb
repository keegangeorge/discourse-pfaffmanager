# frozen_string_literal: true

class CreatePfaffmanagerServer < ActiveRecord::Migration[6.0]
    def change
      create_table :pfaffmanager_servers do |t|
        t.string :hostname, null: false, index: true
        t.string :manager_status_json
        t.string :inventory_repo
        t.string :ssh_key_private
        t.string :ssh_key_public
        t.string :discourse_api_key
        t.references :user
        t.timestamp :manager_status_updated_at
        t.timestamps
      end
    end
  end
