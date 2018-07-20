require File.join(Rails.root,"app","data_migrations","update_aptc_credits.rb")

# This rake task updates the kind field for the given policy to "coverall".
# format RAILS_ENV=production bundle exec rake migrations:udpate_aptc_credits eg_id="abc123" original_start_on="1/1/2018" original_end_on="2/3/108" updated_start_on="1/1/2018" updated_end_on="2/3/108" aptc=100.0 pre_amt_tot=2222 tot_res_amt=23


namespace :migrations do
  desc "update aptc credits"
  UpdateAptcCredits.define_task :update_aptc_credits => :environment
end