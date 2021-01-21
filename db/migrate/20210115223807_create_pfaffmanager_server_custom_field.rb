# frozen_string_literal: true
class CreatePfaffmanagerServerCustomField < ActiveRecord::Migration[6.0]
  def change
    create_table :pfaffmanager_server_custom_fields do |t|
      t.integer :server_id, null: false
      t.string :name, limit: 256, null: false
      t.text :value
      t.timestamps null: false
    end
    add_index :pfaffmanager_server_custom_fields, [:server_id, :name]
  end
end
