class TaxHousehold
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :application_group

  auto_increment :hbx_id, seed: 9999  # Create 'friendly' ID to publish for other systems

  # embedded belongs_to :irs_group association
  field :irs_group_id, type: Moped::BSON::ObjectId

  field :allocated_aptc_in_cents, type: Integer, default: 0
  field :is_active, type: Boolean, default: true   # this TaxHousehold valid?
  field :is_eligibility_determined, type: Boolean, default: false

  field :submitted_date, type: DateTime
  field :effective_start_date, type: DateTime
  field :effective_end_date, type: DateTime
  
  # field :e_pdc_id, type: String  # Eligibility system PDC foreign key

  index({_id: 1})

  embeds_many :tax_household_members
  accepts_nested_attributes_for :tax_household_members

  embeds_many :hbx_enrollments
  accepts_nested_attributes_for :hbx_enrollments
  
  embeds_many :comments
  accepts_nested_attributes_for :comments, reject_if: proc { |attribs| attribs['content'].blank? }, allow_destroy: true

  def parent
    raise "undefined parent ApplicationGroup" unless application_group? 
    self.application_group
  end

  def allocated_aptc_in_dollars=(dollars)
    self.allocated_aptc_in_cents = (Rational(dollars) * Rational(100)).to_i
  end

  def allocated_aptc_in_dollars
    (Rational(allocated_aptc_in_cents) / Rational(100)).to_f if allocated_aptc_in_cents
  end

  def irs_group=(irs_instance)
    return unless irs_instance.is_a? IrsGroup
    self.irs_group_id = irs_instance._id
  end

  def irs_group
    parent.irs_groups.find(self.irs_group_id)
  end

  # Income sum of all tax filers in this Household for specified year
  def total_incomes_by_year
    applicant_links.inject({}) do |acc, per|
      p_incomes = per.financial_statements.inject({}) do |acc, ae|
        acc.merge(ae.total_incomes_by_year) { |k, ov, nv| ov + nv }
      end
      acc.merge(p_incomes) { |k, ov, nv| ov + nv }
    end
  end

  #TODO: return count for adults (21-64), children (<21) and total
  def size
    members.size 
  end

  def self.create_for_people(the_people)
    found = self.where({
      "person_ids" => {
        "$all" => the_people.map(&:id),
        "$size" => the_people.length
       }
    }).first
    return(nil) if found
    self.create!( :people => the_people )
  end

  def subscriber
    #TODO - correct when household has policy association
    people.detect do |person|
      person.members.detect do |member|
        member.enrollees.detect(&:subscriber?)
      end
    end
  end

  def head_of_household
    relationship = application_group.person_relationships.detect { |r| r.relationship_kind == "self" }
    Person.find_by_id(relationship.subject_person)
  end

  def is_eligibility_determined?
    self.is_eligibility_determined
  end

  def is_active?
    self.is_active
  end
end