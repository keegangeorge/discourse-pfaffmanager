# frozen_string_literal: true
require 'byebug'

module Pfaffmanager
  class ServersController < ::ApplicationController
    requires_plugin Pfaffmanager

    before_action :ensure_logged_in

    def index
      Rails.logger.warn "\n\n\n\nServer controller INDEX user #{current_user.username} in the house.\n\n\n\n"
      servers = ::Pfaffmanager::Server.where(user_id: current_user.id)
      Rails.logger.warn "-----------------> Server controller found #{servers.count} servers"
      render_json_dump({ servers: servers })
    end

    def show
      Rails.logger.warn "\n\n\n\nServer controller SHOW for user #{current_user.username} in the house.\n\n\n\n"

      # TODO: Allow admin to see server of other users
      server = ::Pfaffmanager::Server.find_by(user_id: current_user.id, id: params[:id])
      clean_server = server.attributes.except('ssh_key_public')

      #render_json_dump({ server: server, except: [:ssh_key_private ] })
      render_json_dump({ server: clean_server })
    end

    def create_droplet
      server_id = params[:id]
      Rails.logger.warn "servers_controller.create_droplet"
      server = ::Pfaffmanager::Server.find(arams[:server][:user_id])
      server.queue_create_droplet
    end

    def create
      Rails.logger.warn "server controller Creating in Controller!!!!!! user_id: #{params[:server][:user_id]}"
      create_groups = Group.where(name: SiteSetting.pfaffmanager_create_server_group).or(Group.where(name: SiteSetting.pfaffmanager_unlimited_server_group))
      can_create = create_groups && !Group.member_of(create_groups, current_user).empty? || current_user.admin
      if can_create
        Rails.logger.warn "Creating for the group" unless false
        server = ::Pfaffmanager::Server.createServerForUser(params[:server][:user_id])
        group = Group.find_by_name(SiteSetting.pfaffmanager_create_server_group)
        if group
          Rails.logger.warn "Group found: #{group.name}"
          group.remove(current_user) unless current_user.admin
          Rails.logger.warn "removed." unless current_user.admin
        else
          Rails.logger.warn "pfaffmanager_create_server_group not configured."
        end
      else
        Rails.logger.warn "create denied"
        server = {}
      end
      # I don't know why this next line was ever here
      #server = ::Pfaffmanager::Server.find_by(user_id: current_user.id)
      render_json_dump({ server: server })
    end

    def set_server_status
      Rails.logger.warn "Set server status in the contro9ller!!!"
    end

    def update
      Rails.logger.warn "\n\nParams: #{params}\n--> qserver UPDATE controller id: #{params[:id]}\n"
      Rails.logger.warn "\nrequest_status: #{params[:request_status]}"
      server = ::Pfaffmanager::Server.find_by(id: params[:id])
      Rails.logger.warn "Server? Got '#{server.hostname}'"
      manage_group = Group.where(name: SiteSetting.pfaffmanager_server_manager_group)
      # TODO: make 6.months.ago a setting
      can_manage = !Group.member_of(manage_group, current_user).empty? || current_user.admin || server.created_at < 6.months.ago

      if can_manage
        Rails.logger.warn "you can manage"
        request = params[:server][:request].present? ? params[:server][:request].to_i : nil
        Rails.logger.warn "got the request"
      else
        # TODO: raise an error? (Or stop on the front end and dno't worry here)
        Rails.logger.warn "You are not allowed to manage"
      end
      # # TODO: Why not just past the fields rather than a name of a field?
      # # but it requires changing this and Ansible, so I'll leave it 2020-11-12
      # EDIT: maybe I wized up before I used this crazy idea. . .
      # leaving the comment just in case because I'm bad at git
      #      field = params[:server][:field] unless params[:server].nil?
      #      value = params[:server][:value] unless params[:server].nil?
      Rails.logger.warn "gonna look"
      server = ::Pfaffmanager::Server.find_by(id: params[:id])
      Rails.logger.warn "Server? Got '#{server.hostname}'"

      Rails.logger.warn "------------------> GOT REQUEST: #{request}" if request
      if server
        data = server_params
        Rails.logger.warn "\nProcessing server! Data: #{data}"
        Rails.logger.warn "request status nil: #{data[:request_status].nil?}"
        Rails.logger.warn "current admin: #{current_user.admin}"

        if !data[:request_status].nil? && current_user.admin
          # THIS IS A REQUEST STATUS Update--ansible status update
          Rails.logger.warn "update..."
          # ansible updates server status via API
          server.request_status = data[:request_status]
          server.request_status_updated_at = Time.now
          Rails.logger.warn "\n\REQUEST STATUS UPDATE with #{data[:request_status]} at #{server.request_status_updated_at}\n\n"
          # elsif field && value && current_user.admin
          #   Rails.logger.warn 'got a field'
          #   # updates a single field via API
          #   server[field] = value
        elsif !request.nil?
          # a request to do an ansible task like install or rebuild
          Rails.logger.warn "Request exists: #{request}"
           if request >= 0
             server.request = request
           else
             Rails.logger.warn "\n\nprocess running skip rebuild!!\n\n"
           end
           if request > 0
             server.request_status = "Processing"
           end
        else
          Rails.logger.warn "\n\nNORMAL server controller update!"
          # server.user_id = data[:user_id] if data[:user_id]
          # server.hostname = data[:hostname] if data[:hostname]
          server.discourse_api_key = data[:discourse_api_key] if data[:discourse_api_key]
          server.hostname = data[:hostname] if data[:hostname]
          server.do_api_key = data[:do_api_key] unless data[:do_api_key].nil?
          server.mg_api_key = data[:mg_api_key] unless data[:mg_api_key].nil?
          server.maxmind_license_key = data[:maxmind_license_key] unless data[:maxmind_license_key].nil?
          server.smtp_host = data[:smtp_host] unless data[:smtp_host].nil?
          server.smtp_notification_email = data[:smtp_notification_email] unless data[:smtp_notification_email].nil?
          server.smtp_port = data[:smtp_port] unless data[:smtp_port].nil?
          server.smtp_password = data[:smtp_password] unless data[:smtp_password].nil?
          server.smtp_user = data[:smtp_user] unless data[:smtp_user].nil?
          # don't try to start a build if one is running
        end

        Rails.logger.warn "server controller update about to save R: #{server.request}"
        server.save

        if server.errors.present?
          return render_json_error(server.errors.full_messages)
        else
          return render json: success_json.merge(server: server.as_json)
        end
      end

      render json: failed_json
    end

    def server_params
      Rails.logger.warn "server_params . . . processing #{params}"
      params.require(:server).permit(
        :user_id,
        :hostname,
        :do_api_key,
        :mg_api_key,
        :maxmind_license_key,
        :discourse_api_key,
        :request,
        :request_status,
        :smtp_host,
        :smtp_password,
        :smtp_notification_email,
        :smtp_user,
        :smtp_port
      )
    end
  end
end
