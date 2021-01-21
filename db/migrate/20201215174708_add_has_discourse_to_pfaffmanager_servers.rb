# frozen_string_literal: true
class AddHasDiscourseToPfaffmanagerServers < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :has_discourse, :boolean
  end
end
