class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://#{SITE_DOMAIN}/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{SITE_DOMAIN}/"
  end
  
  def forgot_password_token(user)
    setup_email(user)    
    subject    "Reset password request from #{SITE_NAME}"
    body       :user => user
  end  
  
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[SITE_NAME] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
