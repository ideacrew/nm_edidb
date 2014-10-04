class CuramPersonFactory
  def self.create!(options)
    member = Member.new(
      :gender => options[:gender],
      :ssn => options[:ssn],
      :dob => options[:dob]
    )
    Person.create!(
      :name_first => options[:name_first],
      :name_middle => options[:name_middle],
      :name_last => options[:name_last],
      :members => [member]
    )
  end
end

class ImportCuramData
  def initialize(person_factory = CuramPersonFactory, app_group_repo = ApplicationGroup, person_finder = Queries::PersonMatch, app_group_factory = ApplicationGroup, relationship_factory = RelationshipUpdate, qualification_factory = QualificationUpdate, assistance_eligibilities_importer = AddEligibilities)
    @app_group_repo = app_group_repo
    @person_finder = person_finder
    @person_factory = person_factory
    @app_group_factory = app_group_factory
    @relationship_factory = relationship_factory
    @qualification_factory = qualification_factory
    @assistance_eligibilities_importer = assistance_eligibilities_importer
  end

  def qualified_member(person_properties, person)
      [ 
        person.members.detect { |m| m.hbx_member_id == person_properties[:member_id] },
        person.authority_member, 
        person.members.first
      ].detect { |m| !m.nil? }
  end

  def execute(request)
    if(request[:primary_applicant_id].nil?)
      return
    end

    app_group = @app_group_repo.find_by_case_id(request[:e_case_id])
    if(app_group)
      app_group.destroy
    end

    mapped_people = {}
    request[:people].each do |p_hash|
      person = @person_finder.find(p_hash) # Doesn't currently search by member id as far as we know
      if(person.nil?)
        person = @person_factory.create!(p_hash)
      end
      mapped_people[p_hash[:id]] = person
      
      member_id = qualified_member(p_hash, person).hbx_member_id
      @qualification_factory.new(
        {
          :member_id => member_id,
          :is_incarcerated => p_hash[:is_incarcerated],
          :is_state_resident => p_hash[:is_state_resident],
          :citizen_status => p_hash[:citizen_status],
          :is_incarcerated => p_hash[:is_incarcerated],
          :is_state_resident => p_hash[:is_state_resident],
          :citizen_status => p_hash[:citizen_status],
          :e_person_id => p_hash[:e_person_id],
          :e_concern_role_id => p_hash[:e_concern_role_id],
          :aceds_id => p_hash[:aceds_id]
      }).save!
      @assistance_eligibilities_importer.import!(
        person,
        Array(p_hash[:assistance_eligibilities])
      )
    end

    @app_group_factory.create!({
        :e_case_id => request[:e_case_id],
        primary_applicant_id: mapped_people[request[:primary_applicant_id]].id,
        submission_date: request[:submission_date],
        people: mapped_people.values
      })
    request[:relationships].each do |rel|
      @relationship_factory.new({
          :subject_person_id => mapped_people[rel[:subject_person]].id,
          :relationship_kind => rel[:relationship_kind],
          :object_person_id => mapped_people[rel[:object_person]].id
        }).save!
    end
  end
end