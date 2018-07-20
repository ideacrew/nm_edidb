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
    
    it 'updates existing aptc credits' do
        
      policy.aptc_credits.create(start_on: "1/2/2018", end_on: "2/3/2018",aptc: 100, pre_amt_tot: 200, tot_res_amount: 300.5)

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

      expect(policy.aptc_credits.last.start_on).to eq "3/3/2018".to_date
      expect(policy.aptc_credits.last.end_on).to eq "3/4/2018".to_date
      expect(policy.aptc_credits.last.aptc).to eq 1.2.to_d
      expect(policy.aptc_credits.last.tot_res_amt).to eq 2.3.to_d 
      expect(policy.aptc_credits.last.pre_amt_tot).to eq 3.4.to_d 


    end

    it 'updates existing aptc credits among many others' do
      
      policy.aptc_credits.create(start_on: "1/2/2018", end_on: "2/3/2018",aptc: 100, pre_amt_tot: 1234.34, tot_res_amount: 300.5)
      policy.aptc_credits.create(start_on: "2/3/2018", end_on: "2/3/2018",aptc: 100, pre_amt_tot: 200.2, tot_res_amount: 300.5)
      policy.aptc_credits.create(start_on: "3/4/2018", end_on: "2/3/2018",aptc: 100, pre_amt_tot: 200, tot_res_amount: 300.5)

      allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
      allow(ENV).to receive(:[]).with("original_start_on").and_return("3/4/2018")
      allow(ENV).to receive(:[]).with("original_end_on").and_return("2/3/2018")
      allow(ENV).to receive(:[]).with("updated_start_on").and_return("5/6/2018")
      allow(ENV).to receive(:[]).with("updated_end_on").and_return("6/7/2018")
      allow(ENV).to receive(:[]).with("aptc").and_return(1.2)
      allow(ENV).to receive(:[]).with("tot_res_amt").and_return(25.3)
      allow(ENV).to receive(:[]).with("pre_amt_tot").and_return(34.4)

      subject.migrate
      policy.reload

      expect(policy.aptc_credits.last.start_on).to eq "5/6/2018".to_date
      expect(policy.aptc_credits.last.end_on).to eq "6/7/2018".to_date
      expect(policy.aptc_credits.last.aptc).to eq 1.2.to_d
      expect(policy.aptc_credits.last.tot_res_amt).to eq 25.3.to_d 
      expect(policy.aptc_credits.last.pre_amt_tot).to eq 34.4.to_d 

  
      end

    it 'gives error if it cannot find corresponding credits' do

      policy.aptc_credits.create(start_on: "1/2/2018", end_on: "2/3/2018",aptc: 100, pre_amt_tot: 200, tot_res_amount: 300.5)
      

      allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
      allow(ENV).to receive(:[]).with("original_start_on").and_return("12/2018")
      allow(ENV).to receive(:[]).with("original_end_on").and_return("2/3/2018")
      allow(ENV).to receive(:[]).with("updated_start_on").and_return("3/3/2018")
      allow(ENV).to receive(:[]).with("updated_end_on").and_return("3/4/2018")
      allow(ENV).to receive(:[]).with("aptc").and_return(1.2)
      allow(ENV).to receive(:[]).with("tot_res_amt").and_return(2.3)
      allow(ENV).to receive(:[]).with("pre_amt_tot").and_return(3.4)

      subject.migrate
      policy.reload

      expect(subject.migrate).to eq "Unable to find matching APTC credits for policy #{policy.eg_id}"


    end

    it 'gives error if it cannot find corresponding policy' do

      policy.aptc_credits.create(start_on: "1/2/2018", end_on: "2/3/2018",aptc: 100, pre_amt_tot: 200, tot_res_amount: 300.5)
      

      allow(ENV).to receive(:[]).with("eg_id").and_return(23)
      allow(ENV).to receive(:[]).with("original_start_on").and_return("12/2018")
      allow(ENV).to receive(:[]).with("original_end_on").and_return("2/3/2018")
      allow(ENV).to receive(:[]).with("updated_start_on").and_return("3/3/2018")
      allow(ENV).to receive(:[]).with("updated_end_on").and_return("3/4/2018")
      allow(ENV).to receive(:[]).with("aptc").and_return(1.2)
      allow(ENV).to receive(:[]).with("tot_res_amt").and_return(2.3)
      allow(ENV).to receive(:[]).with("pre_amt_tot").and_return(3.4)

      subject.migrate
      policy.reload

      expect(subject.migrate).to eq "unable to find policy 23"

  
      end

    it 'gives error if it policy has no credits' do

  
      allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
      allow(ENV).to receive(:[]).with("original_start_on").and_return("12/2018")
      allow(ENV).to receive(:[]).with("original_end_on").and_return("2/3/2018")
      allow(ENV).to receive(:[]).with("updated_start_on").and_return("3/3/2018")
      allow(ENV).to receive(:[]).with("updated_end_on").and_return("3/4/2018")
      allow(ENV).to receive(:[]).with("aptc").and_return(1.2)
      allow(ENV).to receive(:[]).with("tot_res_amt").and_return(2.3)
      allow(ENV).to receive(:[]).with("pre_amt_tot").and_return(3.4)

      subject.migrate
      policy.reload

      expect(subject.migrate).to eq "no APTC credits found for policy #{policy.eg_id}"


    end
  
  

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
