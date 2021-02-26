module Pfaffmanager
  class ServerSerializer < ApplicationSerializer
    attributes :id,
      :created_at,
      :updated_at,
      :hostname,
      :have_do_api_key,
      :server_status_json,
      :server_status_updated_at,
      :discourse_url,
      :user_id,
      :installed_version,
      :installed_sha,
      :request,
      :request_created_at,
      :request_result,
      :request_status,
      :active,
      :last_action,
      :smtp_host,
      :smtp_notification_email,
      :smtp_password,
      :smtp_port,
      :smtp_user,
      :droplet_size,
      :last_output,
      :install_type

    def have_do_api_key
      "yes"
    end
  end
end
