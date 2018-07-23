eg_ids = %w(100195 100790 100796 100795 100794) 

reason_code = "urn:openhbx:terms:v1:enrollment#terminate_enrollment"

def generate_transaction_id
  transaction_id ||= begin
                        ran = Random.new
                        current_time = Time.now.utc
                        reference_number_base = current_time.strftime("%Y%m%d%H%M%S") + current_time.usec.to_s[0..2]
                        reference_number_base + sprintf("%05i", ran.rand(65535))
                      end
  transaction_id
end

def render_cv(affected_members,policy,event_kind,transaction_id)
  render_result = ApplicationController.new.render_to_string(
        :layout => "enrollment_event",
        :partial => "enrollment_events/enrollment_event",
        :format => :xml,
        :locals => {
          :affected_members => affected_members,
          :policy => policy,
          :enrollees => policy.enrollees,
          :event_type => event_kind,
          :transaction_id => transaction_id
        })
end

policies = Policy.where(:eg_id => {"$in" => eg_ids})

policies.each do |policy|
  affected_members = []
  policy.enrollees.each{|en| affected_members << BusinessProcesses::AffectedMember.new({:policy => policy, :member_id => en.m_id})}
  event_type = reason_code
  tid = generate_transaction_id
  cv_render = render_cv(affected_members,policy,event_type,tid)
  f = File.open("#{policy.eg_id}_#{reason_code.split('#').last}.xml","w")
  f.puts(cv_render)
  f.close
end