class AddSmtpToPfaffmanagerServers < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :smtp_host, :string
    add_column :pfaffmanager_servers, :smtp_password, :string
    add_column :pfaffmanager_servers, :smtp_user, :string
    add_column :pfaffmanager_servers, :smtp_port, :string
    add_column :pfaffmanager_servers, :smtp_notification_email, :string
  end
end
