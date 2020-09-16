class ServerController < ApplicationController
  def index
    Rails.logger.info 'CHOO! 🚂 Called the `ServerController#index` method.'
  end
end