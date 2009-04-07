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

require 'digest/sha1'

class User < ActiveRecord::Base
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100
  
  validates_as_email_address :email

  validates_uniqueness_of    :email
#  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  
  before_create :make_activation_code 
  
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible  :email, :name, :password, :password_confirmation
  
  has_and_belongs_to_many :roles
    
  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end
  
  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  
  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def validate_password
    @validate_password || false
  end
  
  def validate_password=(v)
      @validate_password = v
  end
  
  # Clearout forgot password token
  def reset_forgot_password_fields
    self.forgot_password_token = nil
    self.forgot_password_token_expires_at = nil
    self.save
  end
  
  # Generate tokens for forgot password
  def generate_forgot_password_token
    token = self.object_id.to_s + Time.now.to_i.to_s + rand.to_s
    token = Digest::SHA1.hexdigest(token)
    
    self.forgot_password_token = token
    self.forgot_password_token_expires_at = 24.hours.from_now
    self.save
  end
  
  
  
  # ---------------------------------------
  # The following code has been generated by role_requirement.
  # You may wish to modify it to suit your need
  # has_role? simply needs to return true or false whether a user has a role or not.  
  # It may be a good idea to have "admin" roles return true always
  def has_role?(role_in_question)
    @_list ||= self.roles.collect(&:name)
    return true if @_list.include?("swa")
     (@_list.include?(role_in_question.to_s) )
  end
  # ---------------------------------------
  
    
  
  protected
  
  def make_activation_code
    self.activation_code = self.class.make_token
  end
  
  
end
