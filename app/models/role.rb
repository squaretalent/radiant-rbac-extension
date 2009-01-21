class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  validates_uniqueness_of :role_name
  
  order_by :role_name
  
  class ProtectedRoleError < StandardError; end
  
  before_destroy :verify_non_standard
  
  RADIANT_STANDARDS = ['admin', 'developer']
  
  def verify_non_standard
    if RADIANT_STANDARDS.include?(self[:role_name].to_s)
      # self.errors.add :role_name, "is a protected role and may not be removed."
      raise Role::ProtectedRoleError, "`#{self[:role_name]}' is a protected role and may not be removed."
    end
  end
  
  def remove_user(user)
    if users.size <= 1 && allow_empty == false
      return false
    else
      users.delete(user)
      return true
    end
  end
end