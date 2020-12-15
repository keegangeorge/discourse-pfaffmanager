class AddInstallTypeToPfaffmanagerServers < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :install_type, :string
  end
end
