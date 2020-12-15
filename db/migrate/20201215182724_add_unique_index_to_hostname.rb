class AddUniqueIndexToHostname < ActiveRecord::Migration[6.0]
  def change
    remove_index :pfaffmanager_servers, name: "index_pfaffmanager_servers_on_hostname"
    add_index :pfaffmanager_servers, :hostname, unique: true
  end
end
