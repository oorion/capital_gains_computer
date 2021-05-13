require_relative 'tax'
require 'csv'

def compute_results(filename)
  data = []
  CSV.foreach("/Users/developer/Downloads/#{filename}", headers: true) do |row|
    data.push(row.to_h)
  end
  Tax.new(data).compute
end

def append_results_to_csv(csv, results)
  results.each do |result|
    csv << [result['currency_name'], result['purchase_date'], result['cost_basis'], result['date_sold'], result['proceeds']]
  end
end

year = '2020'
CSV.open("/Users/developer/Downloads/turbotax.csv", "wb") do |csv|
  csv << ['Currency Name','Purchase Date','Cost Basis','Date sold','Proceeds']
  [
    'bch',
    'eth',
    'link',
    'xlm',
    'xrp',
    'xtz',
  ].each do |crypto_name|
    puts crypto_name
    begin
    append_results_to_csv(csv, compute_results("#{year}#{crypto_name}.csv"))
    rescue NoMethodError => e
      require 'pry'; binding.pry
    end
  end
end




# #no difference!
# sorted_bch_results = compute_results('sortedbch.csv')
#
# sorted_bch_total_profit = sorted_bch_results.reduce(0) do |memo, e|
#   memo + e['proceeds'] - e['cost_basis']
# end
# puts "sorted bch total profit: #{sorted_bch_total_profit}"
#
#
# unsorted_bch_results = compute_results('unsortedbch.csv')
#
# unsorted_bch_total_profit = unsorted_bch_results.reduce(0) do |memo, e|
#   memo + e['proceeds'] - e['cost_basis']
# end
# puts "unsorted bch total profit: #{unsorted_bch_total_profit}"