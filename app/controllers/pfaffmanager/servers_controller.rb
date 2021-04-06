# frozen_string_literal: true
require 'byebug'

module Pfaffmanager
  class ServersController < ::ApplicationController
    requires_plugin Pfaffmanager

    before_action :ensure_logged_in
    before_action :set_server
    skip_before_action :set_server, only: [:index, :create]

    def index
      Rails.logger.warn "\n\n\n\nServer controller INDEX user #{current_user.username} in the house.\n\n\n\n"
      puts "\n\n\n\nServer controller INDEX user #{current_user.username} in the house.\n\n\n\n"
      servers = ::Pfaffmanager::Server.where(user_id: current_user.id)
      Rails.logger.warn "-----------------> Server controller found #{servers.count} servers"
      puts "--puts ---------------> Server controller found #{servers.count} servers"
      render json: servers, each_serializer: ServerSerializer
    end

    def show
      Rails.logger.warn "\n\n\n\nServer controller SHOW for user #{current_user.username} in the house.\n\n\n\n"
      render json: @server, serializer: ServerSerializer
    end

    def set_api_key
      # ToDO: require admin for this.
      @server.discourse_api_key = params[:discourse_api_key]
      status = @server.save
      if status
        render plain: "ok"
      else
        render plain: "updating API key failed"
      end
    end

    def get_pub_key
      Rails.logger.warn "\n#{'-' * 40}\nServers controller get_pub_key\n"
      puts "get_pub_key for #{params[:slug]}"

      render plain: @server.ssh_key_public
    end

    def update_status
      puts "\n#{'-' * 40}\nServers controller update_status with #{params}\n"
      Rails.logger.warn "\n#{'-' * 40}\nServers controller update_status with #{params} for #{params[:id]}\n"
      begin
        puts "servers controller going to look for #{params[:id]}"
        puts "found server #{@server.hostname}"
        request_status = params[:request_status]
        @server.log_new_request(request_status)
        @server.request_status = request_status
        @server.request_status_updated_at = Time.now
        @server.active ||= /pfaffmanager-playbook have_vm/.match?(@server.request_status)
        puts "update_status going to save"
        status = @server.save
        if status
          render json: success_json
        else
          render json: failed_json, status: 500
        end
      rescue
        render json: failed_json, status: 500
      end
    end

    def queue_upgrade
      puts "starting servers controller queue_upgrade for #{@server.id} #{@server.hostname}"
      Rails.logger.warn "servers_controller.queue_upgrade for #{@server.id} #{@server.hostname}"
      begin
        return render json: failed_json, status: 404 unless can_upgrade
          puts "server user_id: #{@server.user_id} -- current: #{current_user.id}"
        if (current_user.id != @server.user_id) && !current_user.admin?
          Rails.logger.warn "servers_controller.run_upgrade INVALID ACCESS!!!!!"
          puts "servers_controller.run_upgrade INVALID ACCESS!!!!!"
          render json: failed_json, status: 403
        else
          puts "controller going to queue_upgrade"
          status = @server.queue_upgrade
          @server.log_new_request("Upgrade queued. Waiting to start.")
          puts "controller got #{status}"
          if status
            puts "controller upgrade success"
            render json: @server, serializer: ServerSerializer
          else
            puts "controller upgrade failed"
            render json: failed_json, status: 500
          end
        end
      rescue
        puts "controller upgrade rescue"
        render json: failed_json, status: 500
      end
    end

    def install
      Rails.logger.warn "servers_controller.install for #{@server.id}"
      puts "servers_controller.install for #{@server.id}"
      begin
        puts "server user_id: #{@server.user_id} -- current: #{current_user.id} -- install type: #{@server.install_type}"
        # TODO: this can't happen anymore?
        if (current_user.id != @server.user_id) && !current_user.admin?
          Rails.logger.warn "servers_controller.install INVALID ACCESS!!!!!"
          render json: failed_json, status: 403
        elsif !(DO_INSTALL_TYPES.include?(@server.install_type))
          Rails.logger.warn "servers_controller.install NOT DO INSTALL!!!!!"
          render json: failed_json, status: 501
        else
          Rails.logger.warn "servers_controller going to queue!"
          p "servers_controller going to queue!"
          status = @server.queue_create_droplet
          puts "status is #{status}"
          Rails.logger.warn("logger status #{status}")
          puts "Server: #{@server[:hostname]}"
          puts "last action: #{@server[:last_action]}"
          render json: @server, serializer: ServerSerializer
        end
      rescue
        render json: failed_json, status: 501
      end
    end

    # TODO: make private?
    def can_upgrade
      manage_group = Group.where(name: SiteSetting.pfaffmanager_server_manager_group)
      # TODO: make 6.months.ago a setting
      can_manage = !Group.member_of(manage_group, current_user).empty? || current_user.admin || @server.created_at > 6.months.ago

      if can_manage
        Rails.logger.warn "you can manage"
        puts "you can manage"
      else
        # TODO: raise an error? (Or stop on the front end and dno't worry here)
        Rails.logger.warn "You are not allowed to manage"
        puts "You are not allowed to manage!! created: #{server.created_at}"
      end
      can_manage
    end

    def create
      puts "server controller creating "
      Rails.logger.warn "server controller Creating in Controller!!!!!! "
      create_groups = Group.where(name: SiteSetting.pfaffmanager_create_server_group).or(Group.where(name: SiteSetting.pfaffmanager_unlimited_server_group))
      can_create = create_groups && !Group.member_of(create_groups, current_user).empty? || current_user.admin
      if can_create
        Rails.logger.warn "Creating for the group" unless false
        user_id = current_user.id
        user_id = params[:server][:user_id] if params[:server][:user_id].present? && current_user.admin?
        @server = ::Pfaffmanager::Server.createServerForUser(user_id)
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
        @server = {}
      end
      # I don't know why this next line was ever here
      #server = ::Pfaffmanager::Server.find_by(user_id: current_user.id)
      render_json_dump({ server: @server })
    end

    def update
      Rails.logger.warn "\n\nParams: #{params}\n--> qserver UPDATE controller id: #{params[:id]}\n"
      Rails.logger.warn "\nrequest_status: #{params[:request_status]}"
      Rails.logger.warn "Server? Got '#{@server.hostname}'"

      # TODO: I think that if there's no server we can't get here
      if @server
        data = server_params
        Rails.logger.warn "\nProcessing server! Data: #{data}"
        puts "\nProcessing server! Data: #{data}"
        Rails.logger.warn "request status nil: #{data[:request_status].nil?}"
        Rails.logger.warn "current admin: #{current_user.admin}"
        Rails.logger.warn "droplet size: #{data[:droplet_size]}"

        @server.discourse_api_key = data[:discourse_api_key] if data[:discourse_api_key]
        @server.hostname = data[:hostname] if data[:hostname]
        @server.do_api_key = data[:do_api_key] if data[:do_api_key].present?
        @server.mg_api_key = data[:mg_api_key] if data[:mg_api_key].present?
        @server.maxmind_license_key = data[:maxmind_license_key] if data[:maxmind_license_key].present?
        @server.droplet_size = data[:droplet_size] if data[:droplet_size].present?
        @server.smtp_host = data[:smtp_host] if data[:smtp_host].present?
        @server.smtp_notification_email = data[:smtp_notification_email] if data[:smtp_notification_email].present?
        @server.smtp_port = data[:smtp_port] if data[:smtp_port].present?
        @server.smtp_password = data[:smtp_password] if data[:smtp_password].present?
        @server.smtp_user = data[:smtp_user] if data[:smtp_user].present?

        Rails.logger.warn "server controller update about to save R: #{@server.request} with #{@server.droplet_size}"
        puts "server controller update about to save R: #{@server.request} with #{@server.droplet_size}"
        @server.save
        @server.reload
        puts "Server saved!!! do: #{@server.encrypted_do_api_key.nil?}, mg: #{@server.encrypted_mg_api_key.nil?}"
        data = {
          have_do_api_key: !@server.encrypted_do_api_key.nil?,
          have_mg_api_key: !@server.encrypted_mg_api_key.nil?
        }
        @server.publish_update(data)

        if @server.errors.present?
          return render_json_error(@server.errors.full_messages)
        else
          return render json: @server, serializer: ServerSerializer
        end
      end

      render json: failed_json
    end

    private

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
        :smtp_port,
        :droplet_size
      )
    end

    def set_server
      puts "Set server for #{params[:id]}"
      begin
        if current_user.admin?
          @server = ::Pfaffmanager::Server.find_by(id: params[:id])
        else
          @server = ::Pfaffmanager::Server.find_by(user_id: current_user.id, id: params[:id])
        end
        puts "Set server got #{@server.hostname}"
      rescue
        @server = nil
        raise(SiteSetting.detailed_404 ? ex : Discourse::NotFound)
      end
    end
  end
end
