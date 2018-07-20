require File.join(Rails.root, "lib/mongoid_migration_task")
class UpdateAptcCredits < MongoidMigrationTask
  

  def migrate
    policy = Policy.where(eg_id: ENV['eg_id']).first
    if policy.blank?
      p "unable to find policy #{ENV['eg_id']}"
    elsif policy.aptc_credits.present? 
      credit_matcher(policy)
    else 
      p "no APTC credits found for policy #{policy.eg_id}"
    end

  end

  def credit_matcher(policy)
    original_start_on = ENV['original_start_on']
    original_end_on = ENV['original_end_on']
    updated_start_on = ENV['updated_start_on']
    updated_end_on = ENV['updated_end_on']
    aptc = ENV['aptc']
    pre_amt_tot = ENV['pre_amt_tot']
    tot_res_amt = ENV['tot_res_amt']

    matching_credit = policy.aptc_credits.where(start_on: original_start_on, end_on: original_end_on).first
    if matching_credit 
      matching_credit.update_attributes(start_on: updated_start_on, end_on: updated_end_on, aptc: aptc, pre_amt_tot:pre_amt_tot, tot_res_amt: tot_res_amt)
      policy.save!
      p "APTC credits updated for policy #{policy.eg_id}"
    else
      p "Unable to find matching APTC credits for policy #{policy.eg_id}"   
    end
  end

end