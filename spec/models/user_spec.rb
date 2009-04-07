# == Schema Info
# Schema version: 20090406081344
#
# Table name: users
#
#  id                               :integer(4)      not null, primary key
#  activation_code                  :string(40)
#  crypted_password                 :string(40)
#  email                            :string(100)
#  forgot_password_token            :string(255)
#  name                             :string(100)     default("")
#  remember_token                   :string(40)
#  salt                             :string(40)
#  activated_at                     :datetime
#  created_at                       :datetime
#  forgot_password_token_expires_at :datetime
#  remember_token_expires_at        :datetime
#  updated_at                       :datetime

# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

module UserSpecHelper
  def valid_attributes
    {
     :name => 'Akhil',
     :email => 'akhil@webonrails.com',
     :password => 'hellothere',
     :password_confirmation => 'hellothere'
    }
  end
end


describe User do
  include UserSpecHelper
  fixtures :users, :roles
  
  it "should include Authentication" do
    Authentication::name_regex.should_not be_blank
  end
  
  it "should include Authentication::ByPassword" do
    User.should respond_to(:password_digest)
  end
  
  it "should include Authentication::ByCookieToken" do
    user = User.new
    user.should respond_to(:forget_me)
  end
  
  it "should have name with max. 100 characters" do
    User.should limit_length_of(:name).to(100).using(valid_attributes)
  end
  
  it "should have valid format of name" do
    user = User.new(valid_attributes)
    user.should be_valid
  end
  
  it "should be valid with unique email address" do
    user = User.new(valid_attributes)
    user.should be_valid
    user.save
    user = User.new(valid_attributes)
    user.should_not be_valid
    user.should have(1).error_on(:email)
  end
  
  it "should allow valid email formats only" do
    user = User.new(valid_attributes)
    user.email = 'test@example.co.uk'
    user.should be_valid
    user.email = 'test@Monday the first'
    user.should_not be_valid
    user.should have(1).error_on(:email)
  end
  
  it "should have a method 'activate!' which can activate a user" do
    user = users(:inactive)
    user.activation_code.should_not be_nil
    user.activate!
    user.activation_code.should be_nil
  end
  
  it "should have a method which returns true if user is recently activated" do
    user = users(:inactive)
    user.activate!
    user.activation_code.should be_nil
    user.recently_activated?.should be_true
  end
  
  it "should have a method 'active?' which will return true if user is activated otherwise false" do
    users(:akhil).active?.should be_true
    users(:inactive).active?.should be_false
  end
  
  it "should make activation code before creating new record" do
    user = User.new(valid_attributes)
    user.save
    user.activation_code.should_not be_blank
  end
  
  it "should be able to authenticate a user with correct email and password" do
    user = User.authenticate('akhil@vinsol.com', 'monkey')
    user.should_not be_nil
    user.should eql users(:akhil)
  end
  
  it "should not authenticate if email or password are blank" do
    user = User.authenticate('akhil@vinsol.com', '')
    user.should be_nil
    user = User.authenticate('', 'monkey')
    user.should be_nil
    user = User.authenticate('', '')
    user.should be_nil
  end
  
  it "should not authenticate with invalid email" do
    user = User.authenticate('some_invalid_email@vinsol.com', 'monkey')
    user.should be_nil
  end
  
  it "should not authenticate inactive user" do
    user = User.authenticate('bansal@webonrails.com', 'monkey')
    user.should be_nil
  end
  
  it "should have a method which will convert all upcase character to downcase for email" do
    upcase_email = "AKHIL@vinsol.com"
    user = User.new
    user.email = upcase_email
    user.email.should eql(upcase_email.downcase)
    user.email.should_not eql(upcase_email)
  end
  
  it "should have a method to generate forgot password token" do
    user = users(:akhil)
    user.generate_forgot_password_token
    user.forgot_password_token.should_not be_blank
    user.forgot_password_token_expires_at.should_not be_nil
  end
  
  it "should have a method that can clear out forgot password token" do
    user = users(:akhil)
    user.generate_forgot_password_token
    user.reset_forgot_password_fields
    user.forgot_password_token.should be_blank
    user.forgot_password_token_expires_at.should be_nil
  end
  
  it "should be able to validate role" do
    users(:admin).has_role?(:admin).should be_true
    users(:akhil).has_role?(:user).should be_true
    users(:akhil).has_role?(:admin).should be_false
  end
  
end