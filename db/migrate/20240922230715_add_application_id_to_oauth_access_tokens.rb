class AddApplicationIdToOauthAccessTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :oauth_access_tokens, :application_id, :integer
  end
end
