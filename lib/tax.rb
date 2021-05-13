require 'csv'
require "ostruct"

class Tax
  attr_reader :records
  attr_accessor :buy_records, :output

  def initialize(records)
    @records = records
    @buy_records = []
    @output = []
  end

  def compute
    records.each do |record|
      record = normalize_record(OpenStruct.new(record))
      if record.side == 'BUY'
        buy_records.push(record)
      elsif record.side == 'SELL'
        compute_output(record)
      end
    end
    output
  end

  private

  def normalize_record(record)
    record.total = record.total.to_f < 0 ? record.total.to_f * -1 : record.total.to_f
    record.price = record.price.to_f
    record.size = record.size.to_f
    record
  end

  def compute_output(sell_record)
    if sell_record.size < buy_records[0].size
      compute_when_sell_record_size_less_than_buy_record_size(sell_record)
    elsif sell_record.size == buy_records[0].size
      compute_when_sell_record_size_equal_to_buy_record_size(sell_record)
    elsif sell_record.size > buy_records[0].size
      while sell_record.size > 0
        if sell_record.size > buy_records[0].size
          compute_when_sell_record_size_greater_than_buy_record_size(sell_record)
        elsif sell_record.size == buy_records[0].size
          compute_when_sell_record_size_equal_to_buy_record_size(sell_record)
        elsif sell_record.size < buy_records[0].size
          compute_when_sell_record_size_less_than_buy_record_size(sell_record)
        end
      end
    end
  end

  def compute_when_sell_record_size_less_than_buy_record_size(sell_record)
    buy_record = buy_records.shift
    cost_basis = sell_record.size / buy_record.size * buy_record.total
    output.push(
      {
        'currency_name'=>sell_record['size unit'],
        'purchase_date'=>buy_record['created at'],
        'cost_basis'=>cost_basis.round(2),
        'date_sold'=>sell_record['created at'],
        'proceeds'=>sell_record.total.round(2)
      }
    )
    buy_record.size = buy_record.size - sell_record.size
    buy_record.total = buy_record.total - cost_basis
    buy_records.unshift(buy_record)
    sell_record.size = 0
    sell_record.total = 0
  end

  def compute_when_sell_record_size_equal_to_buy_record_size(sell_record)
    buy_record = buy_records.shift
    output.push(
      {
        'currency_name'=>sell_record['size unit'],
        'purchase_date'=>buy_record['created at'],
        'cost_basis'=>buy_record.total.round(2),
        'date_sold'=>sell_record['created at'],
        'proceeds'=>sell_record.total.round(2),
      }
    )
    sell_record.size = 0
    sell_record.total = 0
  end

  def compute_when_sell_record_size_greater_than_buy_record_size(sell_record)
    buy_record = buy_records.shift
    proceeds = buy_record.size / sell_record.size * sell_record.total
    output.push(
      {
        'currency_name'=>sell_record['size unit'],
        'purchase_date'=>buy_record['created at'],
        'cost_basis'=>buy_record.total.round(2),
        'date_sold'=>sell_record['created at'],
        'proceeds'=>proceeds.round(2)
      }
    )
    sell_record.size = sell_record.size - buy_record.size
    sell_record.total = sell_record.total - proceeds
  end
end