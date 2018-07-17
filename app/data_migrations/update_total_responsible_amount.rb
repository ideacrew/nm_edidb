# Changes the kind field on a policy to "coverall"
require File.join(Rails.root, "lib/mongoid_migration_task")
class UpdateTotalResponsibleAmount < MongoidMigrationTask

  def migrate
    policy = Policy.where(id: ENV['eg_id']).first
    total_responsible_amount= ENV['total_responsible_amount']
    premium_amount_total = ENV['premium_amount_total']
    applied_aptc = ENV['applied_aptc']    

    policy.update_attributes(tot_res_amt: total_responsible_amount) if is_number?(total_responsible_amount)
    policy.update_attributes(pre_amt_tot: premium_amount_total) if is_number?(premium_amount_total)
    policy.update_attributes(applied_aptc: applied_aptc) if is_number?(applied_aptc)
    policy.save!
  end

  def is_number?(string)
    true if Float(string) rescue false
  end

end 

