require 'csv'
field_names= %w(
                Subscriber_name,
                Subscriber_policy_id,
                Subscriber_enrollment_start,
                Subscriber_enrollment_end,
                Employer_legal_name,
                Employer_fein,
                Employer_next_plan_year_start,
                Employer_next_plan_year_end
               )

@csv=CSV.open('report_of_ees_not_renewing.csv', 'w')
@csv << field_names

def current_plan_year(employer)
  current_date = Date.today
  employer.plan_years.where(:start_date => {"$lte" => current_date}, :end_date => {"$gte" => current_date}).first
end

def renewal_plan_year(employer)
  current_date = (Date.today.end_of_month)+1.day
  employer.plan_years.where(:start_date => current_date).first
end

def current_plan_year_policy(person, current_plan_year_effective_dates, policy_type,employer)
  person.policies.to_a.select { |pol| current_plan_year_effective_dates.include?(pol.policy_start) &&
      pol.employer_id == employer._id &&
      pol.coverage_type == policy_type &&
      !pol.canceled? &&
      !pol.terminated?
  }.sort_by { |pol| pol.policy_start }.last
end

def active_renew_policy(person, renewal_plan_year_effective_dates, policy_type, employer)
  person.policies.select { |pol| renewal_plan_year_effective_dates.include?(pol.policy_start) &&
      pol.employer_id == employer._id &&
      pol.coverage_type == policy_type &&
      !pol.canceled?
  }.sort_by { |pol| pol.policy_start }.last
end

Employer.each do |employer|
  current_plan_year = current_plan_year(employer)
  if current_plan_year.blank?
    next
  end
  renewal_plan_year = renewal_plan_year(employer)
  if renewal_plan_year.present?
    employer_policies = Policy.where(:employer_id => employer._id, :enrollees => {"$elemMatch" => {
        :rel_code => "self",
        :coverage_start => {"$gte" => current_plan_year.start_date,
                            "$lte" => current_plan_year.end_date},
        :coverage_end => nil
    }})
    people=employer_policies.map(&:subscriber).map(&:person).uniq
    people.each do |person|
      current_plan_year_effective_dates = (current_plan_year.start_date..current_plan_year.end_date)
      renewal_plan_year_effective_dates = (renewal_plan_year.start_date..renewal_plan_year.end_date)
      non_terminated_current_health_policy = current_plan_year_policy(person, current_plan_year_effective_dates, 'health', employer)
      active_renew_health_policy = active_renew_policy(person, renewal_plan_year_effective_dates, 'health', employer)
      non_terminated_current_dental_policy = current_plan_year_policy(person, current_plan_year_effective_dates, 'dental', employer)
      active_renew_dental_policy= active_renew_policy(person, renewal_plan_year_effective_dates, 'dental', employer)
      if non_terminated_current_health_policy && active_renew_health_policy.blank?
        @csv << [person.full_name,
                non_terminated_current_health_policy.eg_id,
                non_terminated_current_health_policy.policy_start,
                non_terminated_current_health_policy.policy_end,
                employer.name,
                employer.fein,
                renewal_plan_year.start_date,
                renewal_plan_year.end_date
        ]
      end
      if non_terminated_current_dental_policy && active_renew_dental_policy.blank?
        @csv << [person.full_name,
                non_terminated_current_dental_policy.eg_id,
                non_terminated_current_dental_policy.policy_start,
                non_terminated_current_dental_policy.policy_end,
                employer.name,
                employer.fein,
                renewal_plan_year.start_date,
                renewal_plan_year.end_date
        ]
      end
    end
  end
end
