namespace :db do
  desc "This creates default data..."
  task :initialize => :environment do
    Rake::Task["data:roles"].invoke 
    Rake::Task["data:swa"].invoke       
  end
end
