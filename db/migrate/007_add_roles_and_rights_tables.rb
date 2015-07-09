class AddRolesAndRightsTables < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column "name", :string
    end

    create_table :rights do |t|
      t.column "name", :string
      t.column "controller", :string
      t.column "action", :string
    end

    create_table :roles_volunteers, :id => false do |t|
      t.column "role_id", :integer
      t.column "volunteer_id", :integer
    end

    create_table :rights_roles, :id => false do |t|
      t.column "right_id", :integer
      t.column "role_id", :integer
    end

    # create role for volunteers to be bonafide users
    Role.create(:name => 'registered')
    # the 'power user' intern role
    Role.create(:name => 'intern')
  end

  def self.down
    drop_table :roles_volunteers
    drop_table :roles
    drop_table :rights
    drop_table :rights_roles
  end
end
