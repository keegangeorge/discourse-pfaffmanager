# frozen_string_literal: true
module Pfaffmanager
  class ServerSerializer < ApplicationSerializer
    attributes :id,
      :created_at,
      :updated_at,
      :hostname,
      :have_do_api_key,
      :have_mg_api_key,
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
      :request_status_updated_at,
      :ansible_running,
      :active, # we have an active VM with Discourse (mostly?) installed -- should probably be renamed have_vm
      :last_action,
      :smtp_host,
      :smtp_notification_email,
      :smtp_password,
      :smtp_port,
      :smtp_user,
        :available_droplet_sizes,
      :droplet_size,
      :last_output,
     :install_type,
    :do_install_types,
    :ec2_install_types,
    :have_vm

    def have_vm
      object.active.present?
    end

    def have_do_api_key
      object.encrypted_do_api_key.present?
    end

    def ansible_running
      job_started = !object.request_status.nil?
      job_completed = /pfaffmanager-playbook.*(failure|success)/.match?(object.request_status)
      job_started && !job_completed
    end

    def have_mg_api_key
      object.encrypted_mg_api_key.present?
    end

    def available_droplet_sizes
      PfaffmanagerDropletSize.values
    end

    def available_install_types
      PfaffmanagerInstallType.values
    end

    def do_install_types
      ['std', 'lite', 'pro']
    end

    def ec2_install_types
      ['ec2']
    end
  end
end
