class CreateDesignations < ActiveRecord::Migration
  
  def self.up
    create_table  :designations do |t|
      t.integer   :role_id
      t.integer   :user_id
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table    :designations
  end
  
end