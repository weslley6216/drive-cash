require 'rails_helper'

RSpec.describe Refuelings::TankFilterComponent, type: :component do
  it 'renders Tudo, Abastecimentos and Consumo as tabs with Tudo selected on the phone' do
    html = view_context.render(described_class.new)

    tablist = Nokogiri::HTML5.fragment(html).at_css('[role="tablist"]')
    tabs = tablist.css('button[role="tab"]')

    expect(tablist['class']).to eq('flex gap-1 p-1 rounded-xl bg-slate-200/60 w-full')
    expect(tabs.map(&:text)).to eq(%w[Tudo Abastecimentos Consumo])
    expect(tabs.map { |tab| tab['data-tank-filter-kind-param'] }).to eq(%w[all fill route])
    expect(tabs.first['aria-selected']).to eq('true')
    expect(tabs.first['class']).to eq('flex-1 h-9 rounded-lg text-xs font-semibold bg-white text-slate-900 shadow-sm')
    expect(tabs.last['class']).to eq('flex-1 h-9 rounded-lg text-xs font-semibold text-slate-500')
    expect(tabs.first['data-action']).to eq('tank-filter#select')
  end

  it 'sizes the tabs to their labels on the desktop' do
    html = view_context.render(described_class.new(variant: :desktop))

    tablist = Nokogiri::HTML5.fragment(html).at_css('[role="tablist"]')

    expect(tablist['class']).to eq('flex gap-1 p-1 rounded-xl bg-slate-200/60 w-auto')
    expect(tablist.at_css('button')['class']).to start_with('px-4 h-9 rounded-lg')
  end
end
