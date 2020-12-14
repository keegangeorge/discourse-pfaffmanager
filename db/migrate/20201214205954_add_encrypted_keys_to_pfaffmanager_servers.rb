class AddEncryptedKeysToPfaffmanagerServers < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :encrypted_ssh_key_private, :string
    add_column :pfaffmanager_servers, :encrypted_do_api_key, :string
    add_column :pfaffmanager_servers, :encrypted_mg_api_key, :string
  end
end
