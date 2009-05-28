namespace :data do
  desc "Creates default roles."
  task :roles => :environment do
    roles = %w(swa user)
    puts "Creating default #{roles.size} roles: #{roles.to_sentence}" 
    
    roles.each{|r| Role.create(:name => r)}
  end
  
  desc "Create default SWA(site wide admin).."
  task :swa => :environment do
    # Admin Creation
    @user = User.new
    @user.email = "admin@webonrails.com"
    @user.password = "gabbar786"
    @user.password_confirmation = "gabbar786"
    @user.name = "Akhil Bansal"
    if @user.save
      puts "Admin has been created."
      @user.activate!
      @user.roles<< Role.find_by_name('swa')
      @user.save
    else
      puts "Failed to create admin."
      puts "Errors below:"
      puts @user.errors.full_messages
      puts @user.inspect
    end
  end

end
