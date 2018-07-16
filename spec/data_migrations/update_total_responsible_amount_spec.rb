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
      allow(ENV).to receive(:[]).with("policy_id").and_return(policy.id)
      subject.migrate
      policy.reload
      expect(policy.tot_res_amt).to eq BigDecimal.new((8.to_f).to_s)
    end

  end
end