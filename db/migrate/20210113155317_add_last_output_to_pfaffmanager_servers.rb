class AddLastOutputToPfaffmanagerServers < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :last_output, :text
  end
end
