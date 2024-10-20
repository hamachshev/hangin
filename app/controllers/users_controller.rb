class UsersController < ApplicationController
  before_action :doorkeeper_authorize!, only: :add_name
  def add_name

    if user && user.first_name.nil? && user.last_name.nil?
      user.update(first_name: params[:first_name], last_name: params[:last_name])
      render json: user.to_json(only: [:first_name, :last_name, :number])
    end
  end

  private

  def user
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
