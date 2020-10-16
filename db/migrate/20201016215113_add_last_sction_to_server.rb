class AddLastSctionToServer < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :last_action, :string
  end
end
