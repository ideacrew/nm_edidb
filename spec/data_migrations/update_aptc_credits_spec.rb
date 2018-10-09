require "rails_helper"
require File.join(Rails.root,"app","data_migrations","update_aptc_credits.rb")

describe UpdateAptcCredits, dbclean: :after_each do 
  let(:given_task_name) { "update_aptc_credits" }
  let(:policy) { FactoryGirl.create(:policy, applied_aptc:"550", pre_amt_tot:"650",tot_res_amt:"750") }
  let!(:credit) {policy.aptc_credits.create!(start_on:"4/2/2018", end_on:"7/2/2018", pre_amt_tot:"200", tot_res_amt:"100", aptc:"100")}
  subject { UpdateAptcCredits.new(given_task_name, double(:current_scope => nil)) }

  describe "given a task name" do 
    it "has the given task name" do 
      expect(subject.name).to eql given_task_name
    end
  end

  describe "changing the end dates for a policy" do 
    before(:each) do 
      allow(ENV).to receive(:[]).with("policy_id").and_return("")
      allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
      allow(ENV).to receive(:[]).with("start_on").and_return("4/2/2018")
      allow(ENV).to receive(:[]).with("end_on").and_return("6/2/2018")
      allow(ENV).to receive(:[]).with("aptc").and_return("100")
      policy.enrollees.each{|er| er.update_attributes!(coverage_end:nil)  }
    end

    it 'updates aptc credits with matching start and end dates' do  
      subject.migrate
      policy.reload
      credit.reload
      
      expect(credit.pre_amt_tot).to eq 200
      expect(credit.tot_res_amt).to eq 100
    end

    it 'updates aptc credits with matching start and end dates and finds by policy id' do 
      allow(ENV).to receive(:[]).with("policy_id").and_return(policy.id)

      subject.migrate
      policy.reload
      credit.reload
      
      expect(credit.pre_amt_tot).to eq 200
      expect(credit.tot_res_amt).to eq 100
    end

    it 'finds and updates the end date on a credit with no mathcing end day' do 
      allow(ENV).to receive(:[]).with("end_on").and_return("7/2/2018")

      subject.migrate
      policy.reload
      credit.reload
      
      expect(credit.pre_amt_tot).to eq 200
      expect(credit.tot_res_amt).to eq 100
      expect(credit.end_on).to eq Date.new(2018,7,2)
    end

    it 'finds and updates the end date on a credit with no matching end day' do 
      allow(ENV).to receive(:[]).with("end_on").and_return("5/2/2018")
      allow(ENV).to receive(:[]).with("start_on").and_return("4/2/2018")
      allow(ENV).to receive(:[]).with("aptc").and_return("50")
      policy.enrollees.each{|er| er.update_attributes!(coverage_end:nil)  }

      subject.migrate
      policy.reload
      credit.reload

      expect(credit.pre_amt_tot).to eq 200
      expect(credit.tot_res_amt).to eq 150
      expect(credit.end_on).to eq Date.new(2018,5,2)
      expect(credit.start_on).to eq Date.new(2018,4,2)
    end
  end

  describe 'updates aptc credits with matching start and end dates and finds by policy id' do 
      it "updates aptc credits with matching start and end dates and finds by policy id'" do 
      allow(ENV).to receive(:[]).with("policy_id").and_return(policy.id)
      allow(ENV).to receive(:[]).with("end_on").and_return("2/1/2018")
      allow(ENV).to receive(:[]).with("start_on").and_return("4/2/2018")
      allow(ENV).to receive(:[]).with("aptc").and_return("50")
      policy.enrollees.each{|er| er.update_attributes!(coverage_end:nil)  }


      subject.migrate
      policy.reload
      credit.reload

      expect(credit.pre_amt_tot).to eq 200
      expect(credit.tot_res_amt).to eq 150
      expect(credit.aptc).to eq 50
      expect(policy.applied_aptc).to eq 50
      expect(policy.tot_res_amt).to eq policy.pre_amt_tot - policy.applied_aptc

    end
  end
end


