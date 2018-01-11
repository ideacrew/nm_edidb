require 'csv'

only_nfp = []
only_hbx = []

nfp_rows = []
hbx_rows = []

nfp_search_hash = Hash.new { |h, k| h[k] = Array.new }
hbx_search_hash = Hash.new { |h, k| h[k] = Array.new }

def premium_total_amount(pre_amt)
  return 0.00 if pre_amt.blank?
  pre_amt.strip.gsub("$", "").gsub(",", "").to_f
end

def match_row?(nfp_row, hbx_row)
  # normalize the keys by removing spaces so keys match
  hbx_row.keys.each do |k|
    next if k.is_a? Symbol
    hbx_row[k.gsub(' ', '')] = hbx_row[k]
    hbx_row.delete(k)
  end
  nfp_row == hbx_row
end

def is_cancel_garbage?(nfp_row)
  cs = nfp_row['CoverageStart']
  ce = nfp_row['CoverageEnd']
  n_s_id = nfp_row["SubscriberID"]
  n_m_id = nfp_row["MemberID"]
  return true if (n_s_id != n_m_id)
  c_start = Date.parse(cs)
  return true if c_start < Date.new(2014,12,31)
  return false if ce.blank?
  c_end = Date.parse(ce)
  c_end <= c_start
end

CSV.foreach("congressional_audit.csv", headers: true) do |row|
  h_row = row.to_hash
  h_row.merge!(:pre_amt_tot => premium_total_amount(h_row["Premium Total"]))
  hbx_row = [h_row, row.fields]
  hbx_rows << hbx_row
  hbx_search_hash[h_row.to_hash["Subscriber ID"]] = hbx_search_hash[h_row.to_hash["Subscriber ID"]] + [hbx_row] 
end

CSV.foreach("CongressAudit.csv", headers: true, :encoding => 'windows-1251:utf-8') do |row|
  data = row.to_hash
  if !is_cancel_garbage?(data)
    h_row = row.to_hash
    h_row.merge!(:pre_amt_tot => premium_total_amount(h_row["PremiumTotal"]))
    nfp_row = [h_row.to_hash, row.fields]
    nfp_rows << nfp_row
    nfp_search_hash[h_row.to_hash["SubscriberID"]] = nfp_search_hash[h_row.to_hash["SubscriberID"]] + [nfp_row] 
  end
end

CSV.open("nfp_only.csv", "w") do |csv|
  nfp_rows.each do |nfp_row|
    searchable_rows = hbx_search_hash[nfp_row.first["SubscriberID"]]
    unless (searchable_rows.any? { |h_row| match_row?(nfp_row.first, h_row.first) })
      puts nfp_row.first.inspect
      csv << nfp_row.last
    end
  end
end

CSV.open("hbx_only.csv", "w") do |csv|
  hbx_rows.each do |hbx_row|
    searchable_rows = nfp_search_hash[hbx_row.first["Subscriber ID"]]
    unless (searchable_rows.any? { |n_row| match_row?(n_row.first, hbx_row.first) })
      csv << hbx_row.last
    end
  end
end
