require File.join(Rails.root, "lib/mongoid_migration_task")
class CreateAptcCredits < MongoidMigrationTask

  def migrate
    policy = Policy.where(eg_id: ENV['eg_id']).first

    start_on = ENV['start_on']
    end_on = ENV['end_on']
    aptc = ENV['aptc']
    pre_amt_tot = ENV['pre_amt_tot']
    tot_res_amt = ENV['tot_res_amt']

    if policy.blank?
      p "unable to find policy #{ENV['eg_id']}"
    else
       policy.aptc_credits.create(start_on: start_on, end_on: end_on ,aptc: aptc, pre_amt_tot: pre_amt_tot, tot_res_amt: tot_res_amt)
       policy.save!
       p "APTC credits have been created for policy #{policy.eg_id}"
    end

  end

end