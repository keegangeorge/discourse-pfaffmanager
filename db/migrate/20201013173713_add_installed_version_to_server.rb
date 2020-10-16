# frozen_string_literal: true
class AddInstalledVersionToServer < ActiveRecord::Migration[6.0]
  def change
    add_column :pfaffmanager_servers, :installed_version, :string
    add_column :pfaffmanager_servers, :installed_sha, :string
    add_column :pfaffmanager_servers, :git_branch, :string
  end
end
