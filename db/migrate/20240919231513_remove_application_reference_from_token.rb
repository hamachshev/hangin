class RemoveApplicationReferenceFromToken < ActiveRecord::Migration[7.0]
  def change
    remove_reference :oauth_access_tokens, :application, index: true
  end
end
