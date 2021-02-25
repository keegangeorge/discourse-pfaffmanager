class AddDropletSizeToPfaffmanagerServers < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :droplet_size, :string
  end
end
