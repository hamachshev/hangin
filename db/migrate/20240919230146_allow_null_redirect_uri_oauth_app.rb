class AllowNullRedirectUriOauthApp < ActiveRecord::Migration[7.0]
  def change
    change_column_null :oauth_applications, :redirect_uri, true
  end
end
