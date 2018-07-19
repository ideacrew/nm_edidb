require 'pry'
require "rails_helper"
require File.join(Rails.root,"app","data_migrations","update_aptc_credits.rb")

describe UpdateAptcCredits, dbclean: :after_each do
  let(:given_task_name) { "update_aptc_credits" }
  let(:policy) { FactoryGirl.create(:policy)}
  
  subject { UpdateAptcCredits.new(given_task_name, double(:current_scope => nil)) }
  
  describe "given a task name" do 
    it "has the given task name" do 
        expect(subject.name).to eql given_task_name
    end
end

describe "updating aptc credits" do 
    
    it 'updates aptc credits' do
       credit = policy.aptc_credits.create(start_on: "1/2/2018", end_on: "2/3/2018",aptc: 100, pre_amt_tot: 200, tot_res_amount: 300.5)
      
      allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
      allow(ENV).to receive(:[]).with("original_start_on").and_return("1/2/2018")
      allow(ENV).to receive(:[]).with("original_end_on").and_return("2/3/2018")
      allow(ENV).to receive(:[]).with("updated_start_on").and_return("3/3/2018")
      allow(ENV).to receive(:[]).with("updated_end_on").and_return("3/4/2018")
      allow(ENV).to receive(:[]).with("aptc").and_return(1.2)
      allow(ENV).to receive(:[]).with("tot_res_amt").and_return(2.3)
      allow(ENV).to receive(:[]).with("pre_amt_tot").and_return(3.4)

      subject.migrate
      policy.reload

      expect(policy.aptc_credits.first.start_on).to eq "3/3/2018".to_date
      expect(policy.aptc_credits.first.end_on).to eq "3/4/2018".to_date
      expect(policy.aptc_credits.first.aptc).to eq 1.2.to_d
      expect(policy.aptc_credits.first.tot_res_amt).to eq 2.3.to_d 
      expect(policy.aptc_credits.first.pre_amt_tot).to eq 3.4.to_d 



    end

    # it 'update the policy totals  missing total responsible amount' do
    #   allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
    #   allow(ENV).to receive(:[]).with("total_responsible_amount").and_return('')
    #   allow(ENV).to receive(:[]).with("premium_amount_total").and_return(4)
    #   allow(ENV).to receive(:[]).with("applied_aptc").and_return(nil)
    #   subject.migrate
    #   policy.reload
    #   expect(policy.tot_res_amt).to eq policy.tot_res_amt
    #   expect(policy.pre_amt_tot).to eq 4.to_d 
    #   expect(policy.applied_aptc).to eq policy.applied_aptc 

    # end

    # it 'update the policy totals missing premium amount totals' do
    #   allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
    #   allow(ENV).to receive(:[]).with("total_responsible_amount").and_return(5)
    #   allow(ENV).to receive(:[]).with("premium_amount_total").and_return('')
    #   allow(ENV).to receive(:[]).with("applied_aptc").and_return(3)
    #   subject.migrate
    #   policy.reload
    #   expect(policy.tot_res_amt).to eq 5.to_d 
    #   expect(policy.pre_amt_tot).to eq policy.pre_amt_tot
    #   expect(policy.applied_aptc).to eq 3.to_d 

    # end   

    # it 'update the policy totals missing total applied aptc' do
    #   allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
    #   allow(ENV).to receive(:[]).with("total_responsible_amount").and_return(5)
    #   allow(ENV).to receive(:[]).with("premium_amount_total").and_return(4)
    #   allow(ENV).to receive(:[]).with("applied_aptc").and_return('')
    #   subject.migrate
    #   policy.reload
    #   expect(policy.tot_res_amt).to eq 5.to_d 
    #   expect(policy.pre_amt_tot).to eq 4.to_d 
    #   expect(policy.applied_aptc).to eq policy.applied_aptc

    # end

    # it 'update the policy totals with non numbers' do
    #   allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
    #   allow(ENV).to receive(:[]).with("total_responsible_amount").and_return(5)
    #   allow(ENV).to receive(:[]).with("premium_amount_total").and_return(4)
    #   allow(ENV).to receive(:[]).with("applied_aptc").and_return('asdlasjf')
    #   subject.migrate
    #   policy.reload
    #   expect(policy.tot_res_amt).to eq 5.to_d 
    #   expect(policy.pre_amt_tot).to eq 4.to_d 
    #   expect(policy.applied_aptc).to eq policy.applied_aptc

    # end

  end
end
