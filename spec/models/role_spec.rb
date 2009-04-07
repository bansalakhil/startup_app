# == Schema Info
# Schema version: 20090406081344
#
# Table name: roles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime

require File.dirname(__FILE__) + '/../spec_helper'

module RoleSpecHelper
  def valid_attributes
    { :name => 'site_user'}
  end
end

describe Role do
  include RoleSpecHelper
  fixtures :roles, :users  
  
  it "should not be valid without name" do
    Role.should need(:name).using(valid_attributes)
  end
  
  it "should be valid with unique name" do
    Role.should need(:name).to_be_unique.using(valid_attributes)
  end  
  
  it "should have and belongs to many users" do
    role = Role.find :first
    role.should respond_to(:users)
    role.users.should_not be_nil
  end
  
  it "should have a class method 'user' which should return user role" do
    Role.should respond_to(:user)
    Role.user.should eql(roles(:user))
  end

  it "should have a class method 'admin' which should return admin role" do
    Role.should respond_to(:admin)
    Role.admin.should eql(roles(:admin))
  end

end