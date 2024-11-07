class UsersController < ApplicationController
  before_action :doorkeeper_authorize!
  def add_name

    if user && user.first_name.nil? && user.last_name.nil?
      user.update(first_name: params[:first_name], last_name: params[:last_name])
      render json: user.to_json(only: [:first_name, :last_name, :number])
    end
  end

  def add_picture
    if params[:user][:profile_picture].present?
      user.profile_pic.attach(params[:user][:profile_picture])
      if user.save
        user.reload
        render json: user.as_json(only: [:first_name, :last_name]).merge(
          profile_pic: user.profile_pic.attached? ? rails_blob_url(user.profile_pic, disposition: "inline") : nil)

      end
    else
      render json: { errors: user.errors.full_messages }, status: 422
    end
  end
  def update
    if user.update user_params
      render json: user.to_json(only: [:first_name, :last_name])
    else
      render json: { errors: user.errors }, status: 422
    end
  end


  def show
    if user
      if user.profile_pic.attached?
        user.reload
        render json: user.as_json(only: [:first_name, :last_name]).merge(
          profile_pic: rails_blob_url(user.profile_pic, disposition: "inline"))

      else
        render json: user.as_json(only: [:first_name, :last_name]).merge(
          profile_pic: nil
        )
      end
      # render json: user.as_json(only: [:first_name, :last_name]).merge(profile_picture: url_for(user.profile_picture))
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  private

  def user
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end


  def user_params
    params.require(:user).permit(:first_name, :last_name, :profile_picture)
  end
end
