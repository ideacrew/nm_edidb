require "rails_helper"
require File.join(Rails.root,"app","data_migrations","create_aptc_credits.rb")

describe UpdateAptcCredits, dbclean: :after_each do
  let(:given_task_name) { "create_aptc_credits" }
  let(:policy) { FactoryGirl.create(:policy)}
  
  subject { CreateAptcCredits.new(given_task_name, double(:current_scope => nil)) }
  
  describe "given a task name" do 
    it "has the given task name" do 
        expect(subject.name).to eql given_task_name
    end
end

describe "updating aptc credits" do 
    
    it 'updates existing aptc credits' do
        

      allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
      allow(ENV).to receive(:[]).with("start_on").and_return("1/2/2018")
      allow(ENV).to receive(:[]).with("end_on").and_return("2/3/2018")
      allow(ENV).to receive(:[]).with("aptc").and_return(1.2)
      allow(ENV).to receive(:[]).with("tot_res_amt").and_return(2.3)
      allow(ENV).to receive(:[]).with("pre_amt_tot").and_return(3.4)

      subject.migrate
      policy.reload

      expect(policy.aptc_credits.last.start_on).to eq "1/2/2018".to_date
      expect(policy.aptc_credits.last.end_on).to eq "2/3/2018".to_date
      expect(policy.aptc_credits.last.aptc).to eq 1.2.to_d
      expect(policy.aptc_credits.last.tot_res_amt).to eq 2.3.to_d 
      expect(policy.aptc_credits.last.pre_amt_tot).to eq 3.4.to_d 


    end


    it 'gives error if it cannot find corresponding policy' do


      allow(ENV).to receive(:[]).with("eg_id").and_return(23)
      allow(ENV).to receive(:[]).with("start_on").and_return("3/3/2018")
      allow(ENV).to receive(:[]).with("end_on").and_return("3/4/2018")
      allow(ENV).to receive(:[]).with("aptc").and_return(1.2)
      allow(ENV).to receive(:[]).with("tot_res_amt").and_return(2.3)
      allow(ENV).to receive(:[]).with("pre_amt_tot").and_return(3.4)

      subject.migrate
      policy.reload

      expect(subject.migrate).to eq "unable to find policy 23"

  
      end

  end
end
