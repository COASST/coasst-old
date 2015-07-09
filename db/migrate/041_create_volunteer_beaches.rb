class CreateVolunteerBeaches < ActiveRecord::Migration
  extend DataLoader

  def self.up
    create_table :volunteer_beaches do |t|
      t.column :beach_id,     :integer, :null => false
      t.column :volunteer_id, :integer, :null => false
      t.column :frequency,    :integer
    end

    load_data "volunteer_beaches"
  end

  def self.down
    drop_table :volunteer_beaches
  end
end
