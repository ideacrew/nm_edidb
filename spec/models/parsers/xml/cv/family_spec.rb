require 'rails_helper'

describe Parsers::Xml::Cv::FamilyParser do

  let(:family) {
    f = File.open(File.join(Rails.root, "spec", "data", "application_group.xml"))
    f.read
  }

  subject {
    Parsers::Xml::Cv::FamilyParser.parse(family, :single => true)
  }

  let(:individual1) {double(name_last:"Ramirez", name_first:"vroom", name_full:"vroom Ramirez", id:"urn:openhbx:hbx:dc0:resources:v1:dcas:individual#2004542")}

  let(:individual2) {double(name_last:"Pandu De Leon", name_first:"Vicky", name_full:"Vicky De Leon", id:"urn:openhbx:hbx:dc0:resources:v1:dcas:individual#2004818")}

  let(:individuals) {[individual1, individual2]}

  let(:primary_applicant_id) {"urn:openhbx:hbx:dc0:resources:v1:dcas:individual#2004542"}

  let(:submitted_at) {"2013-10-31T18:18:59.000000"}

  let(:e_case_id) {"urn:openhbx:hbx:dc0:resources:v1:curam:integrated_case#2063332"}

  let(:subject_individual_id) {"urn:openhbx:hbx:dc0:dcas:individual#2004542"}

  let(:object_individual_id) {"urn:openhbx:hbx:dc0:dcas:individual#2004818"}

  let(:relationship_uri) {"urn:openhbx:terms:v1:individual_relationship#spouse"}

  let(:family_member_id) {"urn:openhbx:hbx:dc0:resources:v1:dcas:individual#2004542"}

  let(:is_primary_applicant) {"true"}

  let(:sex) {"urn:openhbx:terms:v1:gender#female"}

  let(:ssn) {"171765423"}

  let(:birth_date) {"19890110"}

  let(:tax_filing_status) {"urn:openhbx:terms:v1:tax_filer#non-filer"}

  let(:is_tax_filing_together) {"false"}

  let(:address_line_1) {"21180 SW 59 Terrace"}
  let(:address_line_2) {""}
  let(:location_city_name) {"Nice city"}
  let(:location_state) {"urn:openhbx:terms:v1:us_state#district_of_columbia"}
  let(:location_state_code) {"FL"}
  let(:location_postal_code) {"13171"}
  let(:type) {"urn:openhbx:terms:v1:address_type#home"}

  let(:household_state) {"urn:openhbx:terms:v1:household_state#cs7"}
  let(:maximum_aptc) {"0"}
  let(:csr_percent) {"0.0"}
  let(:determination_date) {"2013-10-31T18:18:59.000000"}


  it 'should return e_case_id' do
    expect(subject.e_case_id).to eql(e_case_id)
  end

  it 'should have 2 people' do
    expect(subject.family_members.length).to eql(2)
  end


  describe "the first applicant" do
    it 'should have the person object)' do
      expect(subject.family_members.first.person.id).to eql(family_member_id)
      expect(subject.family_members.first.person.name_first).to eql(individual1.name_first)
      expect(subject.family_members.first.person.name_last).to eql(individual1.name_last)
      expect(subject.family_members.first.person.name_full).to eql(individual1.name_full)
      expect(subject.family_members.first.person.addresses.first.address_line_1).to eql(address_line_1)
      expect(subject.family_members.first.person.addresses.first.location_city_name).to eql(location_city_name)
      expect(subject.family_members.first.person.addresses.first.location_state).to eql(location_state)
      expect(subject.family_members.first.person.addresses.first.location_state_code).to eql(location_state_code)
      expect(subject.family_members.first.person.addresses.first.type).to eql(type)
      #expect(subject.family_members.first.person.emails).to eql(emails)
      #expect(subject.family_members.first.person.phones).to eql(phones)
    end

    it 'should have person name_first' do
      expect(subject.family_members.first.person.name_first).to eql(individual1.name_first)
    end

    it 'should have person name full' do
      expect(subject.family_members.first.person.name_full).to eql(individual1.name_full)
    end

    it 'should have 1 person relationship with relationship_uri, subject_individual_id, object_individual_id' do
      expect(subject.family_members.first.person_relationships.size).to eq(1)
      expect(subject.family_members.first.person_relationships.first.subject_individual_id).to eq(subject_individual_id)
      expect(subject.family_members.first.person_relationships.first.relationship_uri).to eq(relationship_uri)
      expect(subject.family_members.first.person_relationships.first.object_individual_id).to eq(object_individual_id)
    end

    it 'should have 1 person demographics with ssn, sex, date of birth..' do
      expect(subject.family_members.first.person_demographics.sex).to eq(sex)
      expect(subject.family_members.first.person_demographics.ssn).to eq(ssn)
      expect(subject.family_members.first.person_demographics.birth_date).to eq(birth_date)
    end

    it 'should have 1 financial statement with tax_filing_status, is_tax_filing_together, incomes, deductions, alternative_benefits' do
      expect(subject.family_members.first.financial_statements.size).to eq(1)
      expect(subject.family_members.first.financial_statements.first.tax_filing_status).to eq(tax_filing_status)
      expect(subject.family_members.first.financial_statements.first.is_tax_filing_together).to eq(is_tax_filing_together)
      expect(subject.family_members.first.financial_statements.first.incomes.size).to eq(0)
      expect(subject.family_members.first.financial_statements.first.deductions.size).to eq(0)
      expect(subject.family_members.first.financial_statements.first.alternative_benefits.size).to eq(0)
    end

    it "should return the primary_applicant_id" do
      expect(subject.family_members.first.is_primary_applicant).to eq(is_primary_applicant)
    end
  end

  describe "the second family_member" do

  end

  it "should return the primary_applicant_id" do
    expect(subject.primary_applicant_id).to eq(primary_applicant_id)
  end

  it "should return the submitted_at" do
    expect(subject.submitted_at.to_s).to eq(submitted_at.to_s)
  end

end