require 'rails_helper'

RSpec.describe History::SliceQuery do
  let(:user) { create(:user) }

  def earnings_for(slice) = described_class.new(slice).earnings(user.earnings).to_a
  def expenses_for(slice) = described_class.new(slice).expenses(user.expenses).to_a

  it 'keeps every earning and expense for an empty slice' do
    earning = create(:earning, user: user)
    expense = create(:expense, user: user)

    expect(earnings_for(History::Slice.new)).to eq([earning])
    expect(expenses_for(History::Slice.new)).to eq([expense])
  end

  it 'returns no earnings for an expense slice and no expenses for an earning slice' do
    create(:earning, user: user)
    create(:expense, user: user)

    expect(earnings_for(History::Slice.new(types: %w[expenses]))).to be_empty
    expect(expenses_for(History::Slice.new(types: %w[earnings]))).to be_empty
  end

  it 'keeps only the marked platforms' do
    uber = create(:earning, user: user, platform: 'uber')
    create(:earning, user: user, platform: 'ifood')

    expect(earnings_for(History::Slice.new(platforms: %w[uber]))).to eq([uber])
  end

  it 'keeps only the unpaid expenses with the unpaid switch' do
    unpaid = create(:expense, user: user, paid: false)
    create(:expense, user: user, paid: true)

    expect(expenses_for(History::Slice.new(unpaid: '1'))).to eq([unpaid])
  end

  it 'keeps every vendor of a marked category when none of its vendors is marked' do
    orense = create(:expense, user: user, category: 'fuel', vendor: 'Posto Orense')
    shell = create(:expense, user: user, category: 'fuel', vendor: 'Shell')
    create(:expense, user: user, category: 'meals', vendor: 'Lanchonete')

    expect(expenses_for(History::Slice.new(categories: %w[fuel]))).to contain_exactly(orense, shell)
  end

  it 'narrows a category to its marked vendors while another marked category keeps all of its own' do
    orense = create(:expense, user: user, category: 'fuel', vendor: 'Posto Orense')
    create(:expense, user: user, category: 'fuel', vendor: 'Shell')
    wash = create(:expense, user: user, category: 'car_wash', vendor: 'Lava-rápido Central')
    slice = History::Slice.new(categories: %w[fuel car_wash], vendors: { 'fuel' => ['Posto Orense'] })

    expect(expenses_for(slice)).to contain_exactly(orense, wash)
  end

  it 'matches expenses without a vendor through the no-vendor sentinel, next to a named vendor' do
    nameless = create(:expense, user: user, category: 'car_wash', vendor: nil)
    blank = create(:expense, user: user, category: 'car_wash', vendor: '')
    named = create(:expense, user: user, category: 'car_wash', vendor: 'Lava-rápido Central')
    create(:expense, user: user, category: 'car_wash', vendor: 'Outro')
    slice = History::Slice.new(categories: %w[car_wash],
                               vendors:    { 'car_wash' => [History::Slice::NO_VENDOR, 'Lava-rápido Central'] })

    expect(expenses_for(slice)).to contain_exactly(nameless, blank, named)
  end
end
