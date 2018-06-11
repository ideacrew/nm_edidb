require File.join(Rails.root,"app","data_migrations","mark_policies_for_non_payment.rb")

# This rake task updates the term_for_np field for the given policies to "true".
# format RAILS_ENV=production bundle exec rake migrations:mark_policies_for_non_payment

namespace :migrations do
  desc "Update term_for_np for policy to true"
  MarkPoliciesForNonPayment.define_task :mark_policies_for_non_payment => :environment
end