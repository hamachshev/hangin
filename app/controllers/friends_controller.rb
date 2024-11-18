class FriendsController < ApplicationController
  before_action :doorkeeper_authorize!

  # GET /friends
  def index
    contacts = []
    friends = []
    user.contacts.each do |contact|
      contacts << {
        first_name: contact.first_name,
        last_name: contact.last_name,
        number: contact.number,
        uuid: contact.uuid,
      }
    end
    user.friends.each do |friend|
      friends << {
        first_name: friend.first_name,
        last_name: friend.last_name,
        number: friend.number,
      }
    end
    render json: { contacts: , friends:  }
  end

  # def get_contacts
  #   contacts = user.contacts
  #   render json: contacts.as_json(only: [:id, :first_name, :last_name, :number])
  # end

  # GET /friends/1
  # def show
  #   render json: @friend.as_json(only: [:id, :first_name, :last_name, :number])
  # end

  # POST /friends
  def create
    created_friends = []
    errors = []
    friend_params.each do |friend|
        @friend = user.friends.new(friend)
        if @friend.save
          created_friends << @friend

          User.all.each do |otherUser|
            if otherUser.number == @friend.number[-10..-1] # ie if friend is signed up already TODO and remove country code for now
              user.contacts << otherUser
            end
          end
        else
          errors << {friend: @friend, errors: @friend.errors.full_messages}
        end
        end


  # Send a response with the results -- chat gpt
  if errors.empty?
    render json: created_friends, status: :created
  else
    render json: { result: "Some friends could not be created", created: created_friends, errors: errors }, status: :unprocessable_entity
  end
  end

  # PATCH/PUT /friends/1
  # def update
  #   if @friend.update(friend_params)
  #     render json: @friend
  #   else
  #     render json: @friend.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /friends/1
  # def destroy
  #   @friend.destroy
  # end

  private

  def user
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

    # Only allow a list of trusted parameters through.
    def friend_params
      friend_params_array = params.require(:friends).map do |friend|
        friend.permit(:first_name, :last_name, :number)
      end

      #chatgpt for prompt to edit params after permitting them (but it knew that i wanted to remove the () - from the numbers)
      friend_params_array.each do |friend|
        # Clean the number by removing unwanted characters
        friend[:number] = friend[:number].delete('() -') if friend[:number] #country code TODO
      end

      friend_params_array

    end

  end

