require File.join(Rails.root,"app","data_migrations","update_aptc_credits.rb")

# This rake task updates the kind field for the given policy to "coverall".
# format RAILS_ENV=production bundle exec rake migrations:update_aptc_credits eg_id="abc123" 

namespace :migrations do
  desc "Update kind for policy to coverall"
  UpdateAptcCredits.define_task :update_aptc_credits => :environment
end