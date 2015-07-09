class ModifySurveysTable < ActiveRecord::Migration
  def self.up
    add_column :surveys, :project, :string, :length => 50
  end

  def self.down
    remove_column :surveys, :project
  end
end
