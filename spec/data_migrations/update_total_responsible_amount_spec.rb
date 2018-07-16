require "rails_helper"
require File.join(Rails.root,"app","data_migrations","update_total_responsible_amount.rb")

describe UpdateTotalResponsibleAmount, dbclean: :after_each do
  let(:given_task_name) { "update_total_responsible_amount" }
  let(:policy) { FactoryGirl.create(:policy, pre_amt_tot: BigDecimal.new((10.to_f).to_s), applied_aptc: BigDecimal.new((2.to_f).to_s)) }
  subject { UpdateTotalResponsibleAmount.new(given_task_name, double(:current_scope => nil)) }

  describe "given a task name" do 
    it "has the given task name" do 
      expect(subject.name).to eql given_task_name
    end
  end

  describe "updating total responsible amount" do 

    it 'update the total responsible amount' do
      allow(ENV).to receive(:[]).with("eg_id").and_return(policy.id)
      allow(ENV).to receive(:[]).with("total_responsible_amount").and_return(5)
      allow(ENV).to receive(:[]).with("premium_amount_total").and_return(4)
      allow(ENV).to receive(:[]).with("applied_aptc").and_return(3)
      subject.migrate
      policy.reload
      expect(policy.tot_res_amt).to eq BigDecimal.new((5.to_f).to_s)
      expect(policy.pre_amt_tot).to eq BigDecimal.new((4.to_f).to_s)
      expect(policy.applied_aptc).to eq BigDecimal.new((3.to_f).to_s)

    end

  end
end