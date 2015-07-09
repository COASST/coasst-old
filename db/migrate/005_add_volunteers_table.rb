class AddVolunteersTable < ActiveRecord::Migration
  def self.up
    create_table :volunteers do |t|
      t.column :state_id,         :integer
      t.column :first_name,       :string, :null => false
      t.column :last_name,        :string, :null => false
      t.column :middle_initial,   :string, :limit => 1
      t.column :fullname,         :string # just a composition?
      t.column :email,            :string
      t.column :phone,            :string
      t.column :extension,        :string
      t.column :street_address,   :string
      t.column :city,             :string
      t.column :zip,              :string
      t.column :created_on,       :datetime
      t.column :updated_on,       :datetime
      t.column :ended_on,         :datetime
      t.column :active,           :boolean, :default => true
      # registered user columns, previously in users model
      t.column :hashed_password,  :string
      t.column :salt,             :string
    end
  end

  def self.down
    drop_table :volunteers
  end
end
