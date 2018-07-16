# Changes the kind field on a policy to "coverall"
require File.join(Rails.root, "lib/mongoid_migration_task")
class UpdateTotalResponsibleAmount < MongoidMigrationTask

  def migrate
    policy = Policy.where(id: ENV['policy_id']).first
    total_amount = policy.pre_amt_tot
    new_total_responsible_amount = total_amount - policy.applied_aptc         
    policy.update_attributes(tot_res_amt: new_total_responsible_amount)
    policy.save!
  end

end 

