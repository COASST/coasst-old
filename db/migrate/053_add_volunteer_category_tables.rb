class AddVolunteerCategoryTables < ActiveRecord::Migration
  # volunteer_occupation has links to per-volunteer occupation types
  # volunteer_involvement has links to per-volunteer involvement types

  def self.up

    create_table :involvements do |t|
      t.column :name, :string, :unique => true, :null => false
      t.column :updated_at, :datetime
    end

    create_table :occupations do |t|
      t.column :name, :string, :unique => true, :null => false
      t.column :updated_at, :datetime
    end

    create_table :volunteer_involvement, :id => false do |t|
      t.column :volunteer_id, :integer, :null => false
      t.column :involvement_id, :integer, :null => false
    end

    create_table :volunteer_occupation, :id => false do |t|
      t.column :volunteer_id, :integer, :null => false
      t.column :occupation_id, :integer, :null => false
    end

  end

  def self.down
    drop_table :volunteer_involvement
    drop_table :volunteer_occupation
    drop_table :involvements
    drop_table :occupations
  end
end
