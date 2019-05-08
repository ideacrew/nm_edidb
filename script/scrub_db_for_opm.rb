member_ids_to_keep = %w(
1381456
1883265
1883951
1884042
2738517
182602
2580030
19910622
19910623
19909968
19748089
20009951
20026292
165830
165831
1397064
1397153
18775033
1097127
19894590
19951369
19750753
166339
233166
166341
160360
19749214
20032305
19750719
19966810
19884639
192801
20040768
2045876
19846592
19933618
2737300
2737314
2737322
19782465
19955697
19961296
1191223
10001041
19824664
19989313
170035
19970271
18840564
19967628
2511752
)

employers_to_keep = %w(
118510
100101
100102
)

employer_cross_mapping = {
"118510" => {
  :fein => "111111111",
  :name => "Drug Enforcement Agency",
  :dba => nil
},
"100101" => {
  :fein => "111111112",
  :name => "Social Security Administration",
  :dba => nil
},
"100102" => {
  :fein => "111111113",
  :name => "Office of Personnel Management",
  :dba => nil
}
}

mock_edi_payload_content = "ST*834*1396594*005010X220A1~BGN*00*2018101222040132121205*20181012*220401*UT***2~DTP*303*D8*20181012~QTY*ET*1~QTY*DT*2~QTY*TO*3~N1*P5*Drug Enforcement Agency*FI*111111111~N1*IN*GHMSI_SHP*FI*530078070~INS*Y*18*001*EC*A***AC**N~REF*0F*19748089~REF*17*19748089~DTP*303*D8*20181012~NM1*IL*1*Bolton*Michael****34*666666666~PER*IP**HP*6175551212*EM*Mike.Bolton@example.com~N3*7823 FORREST ST*UNIT 421~N4*SALEM*MA*01970~DMG*D8*19780101*M~LUI*LE*EN**5~HD*030**HLT~DTP*348*D8*20180801~REF*CE*78079DC0220021-01~REF*1L*1064708~LS*2700~LX*1~N1*75*PRE AMT 1~REF*9X*516.63~DTP*007*D8*20180801~LX*2~N1*75*PRE AMT TOT~REF*9X*1413.85~DTP*007*D8*20181010~LX*3~N1*75*TOT RES AMT~REF*9V*353.46~DTP*007*D8*20181010~LX*4~N1*75*TOT EMP RES AMT~REF*9V*1060.39~DTP*007*D8*20181010~LX*5~N1*75*RATING AREA~REF*9X*R-DC001~LX*6~N1*75*REQUEST SUBMIT TIMESTAMP~REF*17*20181012220401~LX*7~N1*75*SEP REASON~REF*17*33-PERSONNEL DATA~LX*8~N1*75*SOURCE EXCHANGE ID~REF*17*DCO~LX*9~N1*75*ADDL MAINT REASON~REF*17*CHANGE~LE*2700~INS*N*01*030*XN*A*****N~REF*0F*19748089~REF*17*20009951~DTP*303*D8*20181012~NM1*IL*1*Bolton*Eliza*N***34*666666667~N3*7823 FORREST ST*UNIT 421~N4*Salem*MA*01970~DMG*D8*19780202*F~LUI*LE*EN**5~HD*030**HLT~DTP*348*D8*20180801~REF*CE*78079DC0220021-01~REF*1L*1064708~LS*2700~LX*1~N1*75*PRE AMT 1~REF*9X*537.01~DTP*007*D8*20180801~LX*2~N1*75*RATING AREA~REF*9X*R-DC001~LX*3~N1*75*REQUEST SUBMIT TIMESTAMP~REF*17*20181012220401~LX*4~N1*75*SOURCE EXCHANGE ID~REF*17*DCO~LE*2700~INS*N*19*021*02*A*****N~REF*0F*19748089~REF*17*20026292~DTP*303*D8*20181012~NM1*IL*1*Bolton*Eliza*Merriam***ZZ*20026292~DMG*D8*20180101*F~LUI*LE*EN**5~HD*021**HLT~DTP*348*D8*20181010~REF*CE*78079DC0220021-01~REF*1L*1064708~LS*2700~LX*1~N1*75*PRE AMT 1~REF*9X*360.21~DTP*007*D8*20181010~LX*2~N1*75*RATING AREA~REF*9X*R-DC001~LX*3~N1*75*REQUEST SUBMIT TIMESTAMP~REF*17*20181012220401~LX*4~N1*75*SOURCE EXCHANGE ID~REF*17*DCO~LE*2700~SE*110*1396594~"

employers = Employer.where(:hbx_id => {"$in" => employers_to_keep})

puts "Found #{employers.count} employers to keep."

employers.each do |emp|
  emp.update_attributes!(
    employer_cross_mapping[emp.hbx_id]
  )
end

Employer.where(:hbx_id => {"$nin" => employers_to_keep}).delete_all

remaining_employer_ids = Employer.all.map(&:_id)

plan_years = PlanYear.where(:employer_id => {"$in" => remaining_employer_ids})

puts "Found #{plan_years.count} plan years to keep."

PlanYear.where(:employer_id => {"$nin" => remaining_employer_ids}).delete_all

kept_policies = Policy.where("enrollees" => {
  "$elemMatch" => {
    "m_id" => {
      "$in" => member_ids_to_keep
    }
  }
})

kept_person_ids = Person.where({
  "members" => {
    "$elemMatch" => {
      "hbx_member_id" => {"$in" => member_ids_to_keep}
    }
  }
}).map(&:id)

policy_ids_to_keep = kept_policies.map(&:id)

puts "Found #{policy_ids_to_keep.length} policies to keep."
puts "Found #{kept_person_ids.length} people to keep."

transmissions_to_keep = Protocols::X12::TransactionSetHeader.where({
  :policy_id => {
    "$in" => policy_ids_to_keep
  },
  "_type" => "Protocols::X12::TransactionSetEnrollment"
}).map(&:transmission_id)

PremiumPayment.where({
  :policy_id => {
    "$nin" => policy_ids_to_keep
  }
}).delete_all

remaining_premium_payment_transaction_ids = PremiumPayment.all.map(&:transaction_set_premium_payment_id)

payment_transmissions_to_keep = Protocols::X12::TransactionSetHeader.where({
  :"_id"=> {
    "$in" => remaining_premium_payment_transaction_ids
  },
  "_type" => "Protocols::X12::TransactionSetPremiumPayment"
}).map(&:transmission_id)

remaining_transmission_ids = (transmissions_to_keep + payment_transmissions_to_keep).uniq

puts "Found #{remaining_transmission_ids.length} transmissions to keep."

tsh_to_remove = Protocols::X12::TransactionSetHeader.where(
  :transmission_id => {
    "$nin" => remaining_transmission_ids
  }
)

puts "Found #{tsh_to_remove.count} TSH to remove."
tsh_to_remove.delete_all

Protocols::X12::Transmission.where(
  "_id" => {
    "$nin" => remaining_transmission_ids
  }
).delete_all

Policy.where("_id" => {
  "$nin" => policy_ids_to_keep
}).delete_all

Person.where("_id" => { "$nin" => kept_person_ids }).delete_all

puts "Scrubbing people"
Person.all.each do |kept_person|
  PersonScrubber.scrub(kept_person.id)
end

total_trans = Protocols::X12::TransactionSetHeader.count

puts "Redacting the EDI content of #{total_trans} transactions..."

db = Mongoid::Sessions.default


all_body_names = Array.new
tsh_col = db["protocols_x12_transaction_set_headers"]
tsh_col.find.each do |doc|
  body_val = doc['body']
  unless body_val.blank?
    all_body_names << ("uploads/" + body_val)
  end
end

db["fs.files"].find({
"filename" => {
"$nin" => all_body_names
}}).remove_all

all_file_ids = Array.new
fs_files = db["fs.files"]
fs_files.find.each do |doc|
  all_file_ids << doc['_id']
end

db["fs.chunks"].find({
"files_id" => {
"$nin" => all_file_ids
}}).remove_all

pb = ProgressBar.create(
:title => "Redacting...",
:total => total_trans,
:format => "%t %a %e |%B| %P%%"
)
Protocols::X12::TransactionSetHeader.all.each do |tse|
  if tse.body.present?
    body_path = tse.body.file.path
    tse.body.remove!
    tse.update_attributes!(:body => FileString.new(body_path.gsub(/uploads\//, ""), mock_edi_payload_content))
  end
  pb.increment
end
pb.finish
