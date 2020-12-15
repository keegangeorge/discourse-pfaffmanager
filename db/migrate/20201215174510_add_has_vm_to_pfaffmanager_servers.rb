class AddHasVmToPfaffmanagerServers < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :has_vm, :boolean
  end
end
