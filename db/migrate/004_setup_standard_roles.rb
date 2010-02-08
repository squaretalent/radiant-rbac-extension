class SetupStandardRoles < ActiveRecord::Migration

  def self.up
    User.send :has_many, :designations, :dependent => :destroy
    User.send :has_many, :roles, :through => :designations
    
    Role.create!(:role_name => 'Admin')
    Role.create!(:role_name => 'Partner')
    Role.create!(:role_name => 'Client')
    
    admins = User.find_all_by_admin(true)
    admins.each do |admin|
      admin.roles << Role.find_by_role_name('Admin')
    end
  end

  def self.down
    say("Removing all Roles.")
    Role.find(:all).map(&:destroy)
  end

end