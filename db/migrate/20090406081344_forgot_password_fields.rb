class ForgotPasswordFields < ActiveRecord::Migration
  def self.up
    add_column :users, :forgot_password_token, :string
    add_column :users, :forgot_password_token_expires_at, :datetime
  end
  
  def self.down
    remove_column :users, :forgot_password_token_expires_at
    remove_column :users, :forgot_password_token
  end
end
