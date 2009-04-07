# == Schema Info
# Schema version: 20090406081344
#
# Table name: roles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime

class Role < ActiveRecord::Base
  
  validates_presence_of :name
  validates_uniqueness_of :name, :unless => Proc.new{|r| r.name.blank?}
  
  has_and_belongs_to_many :users
  
  
  def self.user
    Role.find_by_name('user')
  end
  
  def self.admin
    Role.find_by_name('admin')
  end
  
  
end
