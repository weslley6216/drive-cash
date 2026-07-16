require 'rails_helper'

RSpec.describe Plans::PriceToggleComponent, type: :component do
  subject(:html) { view_context.render(described_class.new(discount_percent: 20)) }

  it 'renders both billing options wired to the stimulus controller' do
    expect(html).to include(I18n.t('plans.toggle.monthly'))
    expect(html).to include(I18n.t('plans.toggle.yearly'))
    expect(html).to include('data-action="click->plan-billing#showMonthly"')
    expect(html).to include('data-action="click->plan-billing#showYearly"')
  end

  it 'advertises the discount and starts on yearly' do
    expect(html).to include('−20%')
    expect(html).to match(/class="[^"]*bg-white text-slate-900 shadow-sm"\s+data-plan-billing-target="yearlyButton"/)
  end
end
