require_relative '../lib/tax'

describe 'tax' do
  it 'should work when sell size is less than buy size' do
    tax = Tax.new(
      [
        {
          'side'=>'BUY',
          'created at'=>'2020-05-06T02:08:09.839Z',
          'size'=>'1.000000',
          'size unit'=>'BCH',
          'price'=>'100.00',
          'total'=>'-101.50',
        },
        {
          'side'=>'SELL',
          'created at'=>'2020-06-11T21:07:42.084Z',
          'size'=>'0.500000',
          'size unit'=>'BCH',
          'price'=>'150.00',
          'total'=>'74',
        }
      ]
    )

    expect(tax.compute).to eq([
      {
        'currency_name'=>'BCH',
        'purchase_date'=>'2020-05-06T02:08:09.839Z',
        'cost_basis'=>50.75,
        'date_sold'=>'2020-06-11T21:07:42.084Z',
        'proceeds'=>74
      }
    ])
    expect(tax.buy_records.map(&:to_h)).to eq([
      {
        :'side'=>'BUY',
        :'created at'=>'2020-05-06T02:08:09.839Z',
        :'size'=>0.5,
        :'size unit'=>'BCH',
        :'price'=>100.00,
        :'total'=>50.75,
      }
    ])
  end

  it 'should work when sell size is equal to buy size' do
    tax = Tax.new(
      [
        {
          'side'=>'BUY',
          'created at'=>'2020-05-06T02:08:09.839Z',
          'size'=>'1.000000',
          'size unit'=>'BCH',
          'price'=>'100.00',
          'total'=>'-101.50',
        },
        {
          'side'=>'SELL',
          'created at'=>'2020-06-11T21:07:42.084Z',
          'size'=>'1.00000',
          'size unit'=>'BCH',
          'price'=>'150.00',
          'total'=>'149',
        }
      ]
    )

    expect(tax.compute).to eq([
      {
        'currency_name'=>'BCH',
        'purchase_date'=>'2020-05-06T02:08:09.839Z',
        'cost_basis'=>101.5,
        'date_sold'=>'2020-06-11T21:07:42.084Z',
        'proceeds'=>149
      }
    ])
    expect(tax.buy_records.map(&:to_h)).to eq([])
  end

  it 'should work when sell size is greater than than buy size using FIFO ' do
    tax = Tax.new(
      [
        {
          'side'=>'BUY',
          'created at'=>'2020-05-06T02:08:09.839Z',
          'size'=>'1.000000',
          'size unit'=>'BCH',
          'price'=>'100.00',
          'total'=>'-101.50',
        },
        {
          'side'=>'BUY',
          'created at'=>'2020-05-07T02:08:09.839Z',
          'size'=>'2.000000',
          'size unit'=>'BCH',
          'price'=>'100.00',
          'total'=>'-201.50',
        },
        {
          'side'=>'SELL',
          'created at'=>'2020-06-11T21:07:42.084Z',
          'size'=>'1.500000',
          'size unit'=>'BCH',
          'price'=>'150.00',
          'total'=>'224',
        }
      ]
    )

    expect(tax.compute).to eq([
      {
        'currency_name'=>'BCH',
        'purchase_date'=>'2020-05-06T02:08:09.839Z',
        'cost_basis'=>101.5.round(2),
        'date_sold'=>'2020-06-11T21:07:42.084Z',
        'proceeds'=>(1/1.5*224).round(2)
      },
      {
        'currency_name'=>'BCH',
        'purchase_date'=>'2020-05-07T02:08:09.839Z',
        'cost_basis'=>(0.5/2*201.5).round(2),
        'date_sold'=>'2020-06-11T21:07:42.084Z',
        'proceeds'=>(0.5/1.5*224).round(2)
      }
    ])

    expect(tax.buy_records.map(&:to_h)).to eq([
      {
        :'side'=>'BUY',
        :'created at'=>'2020-05-07T02:08:09.839Z',
        :'size'=>1.5,
        :'size unit'=>'BCH',
        :'price'=>100.00,
        :'total'=>1.5/2*201.5,
      }
    ])
  end
end

# Currency Name	Purchase Date	Cost Basis	Date sold	Proceeds
