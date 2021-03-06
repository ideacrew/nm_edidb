require 'spec_helper'

shared_examples "a failed CSV import" do |expected_errors|

  it "should add the expected error" do
    expect(csv_slug.last[-2]).to eql("error")
    Array(expected_errors).each do |err|
      expect(csv_slug.last[-1]).to include(err)
    end
  end

end

describe MemberAddressChangers::Csv do
  let(:request) { Struct.new(:person_id, :to_a).new(12354, []) }
  let(:csv_slug) { [] }
  subject { MemberAddressChangers::Csv.new(request, csv_slug) }

  describe "with a policy having a responsible party" do
    before do
      subject.responsible_party_on_policy(:policy_id => "123547")
      subject.fail
    end

    it_behaves_like "a failed CSV import", "- Policy 123547 has a responsible party"
  end

  describe "with a non-existant person" do
    before do
      subject.no_such_person(:person_id => 12354)
      subject.fail
    end

    it_behaves_like "a failed CSV import", "- Person does not exist"
  end

  describe "when the person has more than one active health policy" do
    before do
      subject.too_many_health_policies(:person_id => 12354)
      subject.fail
    end

    it_behaves_like "a failed CSV import", "- has too many active health policies"
  end

  describe "when the person has more than one active dental policy" do
    before do
      subject.too_many_dental_policies(:person_id => 12354)
      subject.fail
    end

    it_behaves_like "a failed CSV import", "- has too many active dental policies"
  end

  describe "when the person has no active policies" do
    before do
      subject.no_active_policies(:person_id => 12354)
      subject.fail
    end

    it_behaves_like "a failed CSV import", "- no active policies"
  end

  describe "when the address is invalid" do
    before do
      subject.invalid_address({:zip_code => ["can't be blank"], :address1 => ["can't be blank"]})
      subject.fail
    end

    it_behaves_like "a failed CSV import", [
      "- Address invalid: zip_code can't be blank",
      "- Address invalid: address1 can't be blank"]
  end

  describe "when successful" do
    before do
      subject.success
    end

    it "should provide a status of 'success'" do
      expect(csv_slug.last[-1]).to eql("success")
    end
  end
end
