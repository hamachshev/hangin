module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = authenticate!
    end

    protected

    def authenticate!
      user = User.find_by(id: doorkeeper_token.try(:resource_owner_id))

      (user && doorkeeper_token&.acceptable?(@_doorkeeper_scopes)) || reject_unauthorized_connection
    end

    def doorkeeper_token
      ::Doorkeeper.authenticate(request)
    end
  end
end
