require File.join(Rails.root,"app","data_migrations","create_aptc_credits.rb")

# This rake task updates the kind field for the given policy to "coverall".
# format RAILS_ENV=production bundle exec rake migrations:create_aptc_credits eg_id="abc123" start_on="1/1/2018" end_on="2/3/108" aptc=100.0 pre_amt_tot=2222 tot_res_amt=123

namespace :migrations do
  desc "Create Aptc Credits"
  CreateAptcCredits.define_task :create_aptc_credits => :environment
end