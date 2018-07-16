# Changes the kind field on a policy to "coverall"

require File.join(Rails.root, "lib/mongoid_migration_task")
class UpdateTotalResponsibleAmount < MongoidMigrationTask

  def migrate
    policy = Policy.where(id: ENV['eg_id']).first
    policy.update_attributes(tot_res_amt: ENV['total_responsible_amount'])
    policy.update_attributes(pre_amt_tot: ENV['premium_amount_total'])
    policy.update_attributes(applied_aptc: ENV['applied_aptc'])
    policy.save!
  end

end 

