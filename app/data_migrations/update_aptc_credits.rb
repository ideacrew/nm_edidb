require File.join(Rails.root, "lib/mongoid_migration_task")

class UpdateAptcCredits < MongoidMigrationTask

  def migrate 


    if Policy.where(eg_id: ENV['policy_id']).first.present? && ENV['eg_id'].blank?
      raise "The policy ID you supplied is also an enrollment group ID. Please double-check that your policy ID is not an enrollment group ID."
    end

    if ENV['policy_id'].present?
      policy = Policy.find(ENV['policy_id'])
    else
      policy = Policy.where(eg_id: ENV['eg_id']).first
    end
    
    start_on = ENV['start_on']
    end_on = ENV['end_on']  
    pre_amt_tot = ENV['pre_amt_tot']
    tot_res_amt = ENV['tot_res_amt'] 
    aptc = ENV['aptc']
    
    unless policy.present?
      raise  "Could not find a policy with the id #{ENV['eg_id']}"
    end

    credit = policy.aptc_credits.where(start_on: start_on).first 
    if credit && credit.end_on == Date.parse(end_on)
      update_credit_amounts(credit,pre_amt_tot, tot_res_amt, aptc)
      puts "APTC credit has been updated to pre_amt_tot: #{credit.pre_amt_tot}, tot_res_amt #{credit.tot_res_amt}, aptc amount: #{credit.aptc}" unless Rails.env.test?
    elsif credit
      update_credit_amounts(credit,pre_amt_tot, tot_res_amt, aptc)
      credit.update_attributes!(end_on: end_on)
      puts "APTC credit has been updated to pre_amt_tot: #{credit.pre_amt_tot}, tot_res_amt #{credit.tot_res_amt}, aptc amount: #{credit.aptc}, end_on: #{credit.end_on}" unless Rails.env.test?
    else
      credit = policy.aptc_credits.create!(start_on: start_on, end_on: end_on, pre_amt_tot: pre_amt_tot,tot_res_amt:tot_res_amt, aptc: aptc)
      puts "New aptc credit has been created for policy #{policy.eg_id} with pre_amt_tot: #{credit.pre_amt_tot}, tot_res_amt #{credit.tot_res_amt}, aptc amount: #{credit.aptc}  start_on: #{credit.start_on}, end_on: #{credit.end_on}" unless Rails.env.test?
    end
  end

  def is_number?(string)
    true if Float(string) rescue false
  end

  def update_credit_amounts(credit, pre_amt_tot, tot_res_amt,aptc)
    credit.update_attributes!(pre_amt_tot: pre_amt_tot) if is_number?(pre_amt_tot)
    credit.update_attributes!(tot_res_amt: tot_res_amt) if is_number?(tot_res_amt)
    credit.update_attributes!(aptc: aptc) if is_number?(aptc)
  end

end
