class ForgotPassword < ActiveRecord::Migration
  def self.up
    add_column :volunteers, :reset_password_code, :string
    add_column :volunteers, :reset_password_code_until, :datetime
  end

  def self.down
    remove_column :volunteers, :reset_password_code
    remove_column :volunteers, :reset_password_code_until
  end
end
