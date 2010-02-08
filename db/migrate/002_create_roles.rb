class CreateRoles < ActiveRecord::Migration
  
  def self.up
    create_table :roles do |t|
      t.column :role_name,    :string, :limit => 64, :default => "New Role"
      t.column :description,  :string
      t.column :allow_empty,  :boolean, :default => true
      t.column :created_by_id, :integer
      t.column :updated_by_id, :integer
    end
  end

  def self.down
    drop_table :roles
  end
  
end