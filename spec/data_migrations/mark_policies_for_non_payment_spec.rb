require "rails_helper"
require File.join(Rails.root,"app","data_migrations","mark_policies_for_non_payment")

describe MarkPoliciesForNonPayment, dbclean: :after_each do
  let(:given_task_name) { "mark_policies_for_non_payment" }
  # policy factory generates a policy with the kind atrribute set to "individual" by default
  # this will verify that the rake task is actually making a change and that the test instance
  # does not have the correct value already
  let!(:policy) { FactoryGirl.create(:policy, aasm_state: "terminated") }
  subject { MarkPoliciesForNonPayment.new(given_task_name, double(:current_scope => nil)) }

  describe "given a task name" do
    it "has the given task name" do
      expect(subject.name).to eql given_task_name
    end
  end

  describe "updating the term_for_np field to be true" do
    before(:each) do
      allow(ENV).to receive(:[]).with("policy_id").and_return(policy.id)
    end

    it "should initially be set to false" do
      expect(policy.term_for_np).to eq false
    end

    it "should be set to true after the rake task is complete" do
      subject.migrate
      policy.reload
      expect(policy.term_for_np).to eq true
    end
  end
end