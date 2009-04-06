# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  include AuthenticatedSystem
  include RoleRequirementSystem
  
  before_filter :current_user
  
  helper_method  :back_or_default
  
  
  
  def back_or_default
    if request.env["HTTP_REFERER"]
      return request.env["HTTP_REFERER"]
    else
      return root_path
    end
  end
  
  
end
