class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  
  # render new.rhtml
  def new
    @user = User.new
  end
  
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.roles<< Role.user
    success = @user && @user.save
    if success && @user.errors.empty?
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end
  
  
  # Forgot password functionality to make a reset password functionality
  def forgot_password
    @user = User.new if request.get?
    
    if request.post?
        @user = User.find_by_email params[:user][:email]
        if @user.nil?
          @user = User.new
          flash[:error] = "Could not find user with this email."
        else
          @user.generate_forgot_password_token
          UserMailer.deliver_forgot_password_token(@user)
          flash.now[:notice] = "We have sent you a mail at #{@user.email}, please follow the instructions in the mail."
          @user = User.new
        end
    end
  end 
  

  def reset_password
    # redirect if no token found
    check_for_forgot_token

    @user = User.new
    if request.post? and !params[:token].blank?
      @user=User.find_by_forgot_password_token(params[:token])
      
      if  Time.now <= @user.forgot_password_token_expires_at
        respond_to do |format|
          @user.validate_password = true
          if @user.update_attributes(params[:user])
            flash[:notice] = 'Password was successfully updated.'
            @user.reset_forgot_password_fields
            format.html { redirect_to(login_path) }
            format.xml { head :ok }
          else
            format.html { render :action => "reset_password" }
            format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
          end
        end
      else
        flash[:error] = 'Your reset password url has been expired'
        format.html { render :action => "reset_password" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
  
  
  private 
  
  def check_for_forgot_token
    if params[:token].blank?
      flash[:error] = "Page you are looking does not exists"
      redirect_to root_path and return
    end
    
    @user = User.find_by_forgot_password_token(params[:token])
    if @user.nil?
      flash[:error] = "Invalid token"
      redirect_to root_path and return
    end

  end

end
