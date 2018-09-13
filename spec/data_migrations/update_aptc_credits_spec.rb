



require "rails_helper"
require File.join(Rails.root,"app","data_migrations","update_aptc_credits.rb")

describe UpdateAptcCredits, dbclean: :after_each do 
  let(:given_task_name) { "update_aptc_credits" }
  let(:policy) { FactoryGirl.create(:policy) }
  let(:enrollees) { policy.enrollees }
  let!(:credit) {policy.aptc_credits.create!(start_on:"4/2/2018", end_on:"6/2/2018", pre_amt_tot:"123", tot_res_amt:"245")}
  subject { UpdateAptcCredits.new(given_task_name, double(:current_scope => nil)) }

  describe "given a task name" do 
    it "has the given task name" do 
      expect(subject.name).to eql given_task_name
    end
  end

  describe "changing the end dates for a policy" do 
    before(:each) do 

      allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
      allow(ENV).to receive(:[]).with("start_on").and_return("4/2/2018")
      allow(ENV).to receive(:[]).with("end_on").and_return("6/2/2018")
      allow(ENV).to receive(:[]).with("tot_res_amt").and_return("23")
      allow(ENV).to receive(:[]).with("pre_amt_tot").and_return("765")
      allow(ENV).to receive(:[]).with("aptc").and_return("889")
    
      policy.aptc_credits.create!(start_on:"4/2/2018", end_on:"6/2/2018", pre_amt_tot:"123", tot_res_amt:"245", aptc:"67") 
    end

    it 'updates aptc credits with matching start and end dates' do  
      subject.migrate
      policy.reload
      credit.reload
      
      expect(credit.pre_amt_tot).to eq 765.to_d
      expect(credit.tot_res_amt).to eq 23.to_d
    end

    it 'finds and updates the end date on a credit with no mathcing end day' do 
      allow(ENV).to receive(:[]).with("end_on").and_return("7/2/2018")

      policy.aptc_credits.create!(start_on:"2/2/2018", end_on:"7/2/2018", pre_amt_tot:"12", tot_res_amt:"245", aptc:"67")
      subject.migrate
      policy.reload
      credit.reload
      
      expect(credit.pre_amt_tot).to eq 765.to_d
      expect(credit.tot_res_amt).to eq 23.to_d
      expect(credit.end_on).to eq Date.parse("7/2//2018")

    end

    it 'finds and updates the end date on a credit with no mathcing end day' do 
      allow(ENV).to receive(:[]).with("end_on").and_return("8/2/2018")
      allow(ENV).to receive(:[]).with("start_on").and_return("1/2/2018")
      allow(ENV).to receive(:[]).with("tot_res_amt").and_return("100")
      allow(ENV).to receive(:[]).with("pre_amt_tot").and_return("200")
      allow(ENV).to receive(:[]).with("aptc").and_return("300")

      subject.migrate
      policy.reload

      credit= policy.aptc_credits.where(start_on: Date.parse("1/2/2018")).first
      
      expect(credit.pre_amt_tot).to eq 200.to_d
      expect(credit.tot_res_amt).to eq 100.to_d
      expect(credit.end_on).to eq Date.parse("8/2/  2018")
      expect(credit.start_on).to eq Date.parse("1/2/2018")

    end
  end
end


